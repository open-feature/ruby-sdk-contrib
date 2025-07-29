# frozen_string_literal: true

require "open_feature/sdk"
require "net/http"
require "json"
require "faraday"
require "faraday/net_http_persistent"
require_relative "error/errors"
require_relative "model/ofrep_api_response"

module OpenFeature
  module GoFeatureFlag
    # This class is the entry point for the GoFeatureFlagProvider
    class GoFeatureFlagApi
      def initialize(endpoint: nil, custom_headers: nil)
        @faraday_connection = Faraday.new(url: endpoint, headers: custom_headers) do |f|
          f.adapter :net_http_persistent do |http|
            http.idle_timeout = 30
          end
        end
      end

      def evaluate_ofrep_api(flag_key:, evaluation_context:)
        unless @retry_after.nil?
          if Time.now < @retry_after
            raise OpenFeature::GoFeatureFlag::RateLimited.new(nil)
          else
            @retry_after = nil
          end
        end

        evaluation_context = OpenFeature::SDK::EvaluationContext.new if evaluation_context.nil?
        # replace targeting_key by targetingKey
        evaluation_context.fields["targetingKey"] = evaluation_context.targeting_key
        evaluation_context.fields.delete("targeting_key")

        response = @faraday_connection.post("/ofrep/v1/evaluate/flags/#{flag_key}") do |req|
          req.body = {context: evaluation_context.fields}.to_json
        end

        case response.status
        when 200
          parse_success_response(response)
        when 400
          parse_error_response(response)
        when 401, 403
          raise OpenFeature::GoFeatureFlag::UnauthorizedError.new(response)
        when 404
          raise OpenFeature::GoFeatureFlag::FlagNotFoundError.new(response, flag_key)
        when 429
          parse_retry_later_header(response)
          raise OpenFeature::GoFeatureFlag::RateLimited.new(response)
        else
          raise OpenFeature::GoFeatureFlag::InternalServerError.new(response)
        end
      end

      private

      def headers(custom_headers)
        {"Content-Type" => "application/json"}.merge(custom_headers || {})
      end

      def parse_error_response(response)
        required_keys = %w[key error_code]
        parsed = JSON.parse(response.body)

        missing_keys = required_keys - parsed.keys
        unless missing_keys.empty?
          raise OpenFeature::GoFeatureFlag::ParseError.new(response)
        end

        OpenFeature::GoFeatureFlag::OfrepApiResponse.new(
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
          raise OpenFeature::GoFeatureFlag::ParseError.new(response)
        end

        OpenFeature::GoFeatureFlag::OfrepApiResponse.new(
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
        reason_str = reason_str.upcase
        reason_map = {
          "STATIC" => SDK::Provider::Reason::STATIC,
          "DEFAULT" => SDK::Provider::Reason::DEFAULT,
          "TARGETING_MATCH" => SDK::Provider::Reason::TARGETING_MATCH,
          "SPLIT" => SDK::Provider::Reason::SPLIT,
          "CACHED" => SDK::Provider::Reason::CACHED,
          "DISABLED" => SDK::Provider::Reason::DISABLED,
          "UNKNOWN" => SDK::Provider::Reason::UNKNOWN,
          "STALE" => SDK::Provider::Reason::STALE,
          "ERROR" => SDK::Provider::Reason::ERROR
        }
        reason_map[reason_str] || SDK::Provider::Reason::UNKNOWN
      end

      def error_code_mapper(error_code_str)
        error_code_str = error_code_str.upcase
        error_code_map = {
          "PROVIDER_NOT_READY" => SDK::Provider::ErrorCode::PROVIDER_NOT_READY,
          "FLAG_NOT_FOUND" => SDK::Provider::ErrorCode::FLAG_NOT_FOUND,
          "PARSE_ERROR" => SDK::Provider::ErrorCode::PARSE_ERROR,
          "TYPE_MISMATCH" => SDK::Provider::ErrorCode::TYPE_MISMATCH,
          "TARGETING_KEY_MISSING" => SDK::Provider::ErrorCode::TARGETING_KEY_MISSING,
          "INVALID_CONTEXT" => SDK::Provider::ErrorCode::INVALID_CONTEXT,
          "GENERAL" => SDK::Provider::ErrorCode::GENERAL
        }
        error_code_map[error_code_str] || SDK::Provider::ErrorCode::GENERAL
      end

      def parse_retry_later_header(response)
        retry_after = response["Retry-After"]
        return nil if retry_after.nil?

        begin
          @retry_after = if /^\d+$/.match?(retry_after)
                           # Retry-After is in seconds
                           Time.now + Integer(retry_after)
                         else
                           # Retry-After is an HTTP-date
                           Time.httpdate(retry_after)
                         end
        rescue ArgumentError
          # ignore invalid Retry-After header
          nil
        end
      end
    end
  end
end
