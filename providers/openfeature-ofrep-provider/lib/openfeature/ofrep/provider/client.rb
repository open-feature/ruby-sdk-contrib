# frozen_string_literal: true

require "cgi"
require "json"
require "open_feature/sdk"
require "faraday/net_http_persistent"
require_relative "errors"
require_relative "response"

module OpenFeature
  module OFREP
    class Client
      REASON_MAP = {
        "STATIC" => SDK::Provider::Reason::STATIC,
        "DEFAULT" => SDK::Provider::Reason::DEFAULT,
        "TARGETING_MATCH" => SDK::Provider::Reason::TARGETING_MATCH,
        "SPLIT" => SDK::Provider::Reason::SPLIT,
        "CACHED" => SDK::Provider::Reason::CACHED,
        "DISABLED" => SDK::Provider::Reason::DISABLED,
        "UNKNOWN" => SDK::Provider::Reason::UNKNOWN,
        "STALE" => SDK::Provider::Reason::STALE,
        "ERROR" => SDK::Provider::Reason::ERROR
      }.freeze

      ERROR_CODE_MAP = {
        "PROVIDER_NOT_READY" => SDK::Provider::ErrorCode::PROVIDER_NOT_READY,
        "FLAG_NOT_FOUND" => SDK::Provider::ErrorCode::FLAG_NOT_FOUND,
        "PARSE_ERROR" => SDK::Provider::ErrorCode::PARSE_ERROR,
        "TYPE_MISMATCH" => SDK::Provider::ErrorCode::TYPE_MISMATCH,
        "TARGETING_KEY_MISSING" => SDK::Provider::ErrorCode::TARGETING_KEY_MISSING,
        "INVALID_CONTEXT" => SDK::Provider::ErrorCode::INVALID_CONTEXT,
        "GENERAL" => SDK::Provider::ErrorCode::GENERAL
      }.freeze

      def initialize(configuration:)
        @configuration = configuration
        @retry_lock = Mutex.new
        request_options = {timeout: configuration.timeout}
        @faraday_connection = Faraday.new(
          url: configuration.base_url,
          headers: build_headers,
          request: request_options
        ) do |f|
          f.adapter :net_http_persistent do |http|
            http.idle_timeout = 30
          end
        end
      end

      def evaluate(flag_key:, evaluation_context:)
        check_retry_after
        request = evaluation_request(evaluation_context)

        response = @faraday_connection.post("/ofrep/v1/evaluate/flags/#{CGI.escape(flag_key)}") do |req|
          req.body = request.to_json
        end

        case response.status
        when 200
          parse_success_response(response)
        when 400
          parse_error_response(response)
        when 401, 403
          raise OpenFeature::OFREP::UnauthorizedError.new(response)
        when 404
          raise OpenFeature::OFREP::FlagNotFoundError.new(response, flag_key)
        when 429
          parse_retry_later_header(response)
          raise OpenFeature::OFREP::RateLimited.new(response)
        else
          raise OpenFeature::OFREP::InternalServerError.new(response)
        end
      end

      private

      def build_headers
        {"Content-Type" => "application/json"}.merge(@configuration.headers || {})
      end

      def evaluation_request(evaluation_context)
        ctx = evaluation_context
        fields = ctx.fields.dup
        fields["targetingKey"] = ctx.targeting_key
        fields.delete("targeting_key")

        {context: fields}
      end

      def check_retry_after
        @retry_lock.synchronize do
          return if @retry_after.nil?
          if Time.now < @retry_after
            raise OpenFeature::OFREP::RateLimited.new(nil)
          else
            @retry_after = nil
          end
        end
      end

      def parse_error_response(response)
        required_keys = %w[key error_code]
        parsed = JSON.parse(response.body)

        missing_keys = required_keys - parsed.keys
        unless missing_keys.empty?
          raise OpenFeature::OFREP::ParseError.new(response)
        end

        OpenFeature::OFREP::Response.new(
          value: nil,
          key: parsed["key"],
          reason: SDK::Provider::Reason::ERROR,
          variant: nil,
          error_code: error_code_mapper(parsed["error_code"]),
          error_details: parsed["error_details"],
          metadata: nil
        )
      end

      def parse_success_response(response)
        required_keys = %w[key value reason variant]
        parsed = JSON.parse(response.body)

        missing_keys = required_keys - parsed.keys
        unless missing_keys.empty?
          raise OpenFeature::OFREP::ParseError.new(response)
        end

        OpenFeature::OFREP::Response.new(
          value: parsed["value"],
          key: parsed["key"],
          reason: reason_mapper(parsed["reason"]),
          variant: parsed["variant"],
          error_code: nil,
          error_details: nil,
          metadata: parsed["metadata"]
        )
      end

      def reason_mapper(reason_str)
        return SDK::Provider::Reason::UNKNOWN if reason_str.nil?
        REASON_MAP[reason_str.upcase] || SDK::Provider::Reason::UNKNOWN
      end

      def error_code_mapper(error_code_str)
        return SDK::Provider::ErrorCode::GENERAL if error_code_str.nil?
        ERROR_CODE_MAP[error_code_str.upcase] || SDK::Provider::ErrorCode::GENERAL
      end

      def parse_retry_later_header(response)
        retry_after = response["Retry-After"]
        return nil if retry_after.nil?

        begin
          next_retry_time =
            if /^\d+$/.match?(retry_after)
              Time.now + Integer(retry_after)
            else
              Time.httpdate(retry_after)
            end
          @retry_lock.synchronize do
            @retry_after = [@retry_after, next_retry_time].compact.max
          end
        rescue ArgumentError
          nil
        end
      end
    end
  end
end
