# frozen_string_literal: true

require "open_feature/sdk"
require "net/http"
require "json"
require_relative "error/errors"
require_relative "model/ofrep_api_response"

module OpenFeature
  module GoFeatureFlag
    # This class is the entry point for the GoFeatureFlagProvider
    class GoFeatureFlagApi
      attr_reader :options
      def initialize(options: {})
        options = OpenFeature::GoFeatureFlag::Options.new unless options.is_a?(OpenFeature::GoFeatureFlag::Options)
        @options = options
      end

      def evaluate_ofrep_api(flag_key:, evaluation_context:)
        unless @retry_after.nil?
          if Time.now < @retry_after
            raise OpenFeature::GoFeatureFlag::RateLimited.new(nil)
          else
            @retry_after = nil
          end
        end

        evaluation_context = OpenFeature::SDK::EvaluationContext.new unless evaluation_context.is_a?(OpenFeature::SDK::EvaluationContext)
        # Format the URL to call the Go Feature Flag OFREP API
        base_uri = URI.parse(@options.endpoint)
        new_path = File.join(base_uri.path, "/ofrep/v1/evaluate/flags/#{flag_key}")
        ofrep_uri = base_uri.dup
        ofrep_uri.path = new_path

        # Initialize the HTTP client
        http = Net::HTTP.new(ofrep_uri.host, ofrep_uri.port)
        http.use_ssl = (ofrep_uri.scheme == "https")

        # Prepare the headers
        headers = {
          "Content-Type" => "application/json"
        }
        if @options.custom_headers.nil?
          headers.merge!(@options.custom_headers)
        end

        request = Net::HTTP::Post.new(ofrep_uri.path, headers)

        # replace targetingKey
        evaluation_context.fields["targetingKey"] = evaluation_context.targeting_key
        evaluation_context.fields.delete("targeting_key")

        request.body = {context: evaluation_context.fields}.to_json
        response = http.request(request)

        case response.code.to_i
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
          reason: OpenFeature::SDK::Provider::Reason::ERROR,
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
          "STATIC" => OpenFeature::SDK::Provider::Reason::STATIC,
          "DEFAULT" => OpenFeature::SDK::Provider::Reason::DEFAULT,
          "TARGETING_MATCH" => OpenFeature::SDK::Provider::Reason::TARGETING_MATCH,
          "SPLIT" => OpenFeature::SDK::Provider::Reason::SPLIT,
          "CACHED" => OpenFeature::SDK::Provider::Reason::CACHED,
          "DISABLED" => OpenFeature::SDK::Provider::Reason::DISABLED,
          "UNKNOWN" => OpenFeature::SDK::Provider::Reason::UNKNOWN,
          "STALE" => OpenFeature::SDK::Provider::Reason::STALE,
          "ERROR" => OpenFeature::SDK::Provider::Reason::ERROR
        }
        reason_map[reason_str] || OpenFeature::SDK::Provider::Reason::UNKNOWN
      end

      def error_code_mapper(error_code_str)
        error_code_str = error_code_str.upcase
        error_code_map = {
          "PROVIDER_NOT_READY" => OpenFeature::SDK::Provider::ErrorCode::PROVIDER_NOT_READY,
          "FLAG_NOT_FOUND" => OpenFeature::SDK::Provider::ErrorCode::FLAG_NOT_FOUND,
          "PARSE_ERROR" => OpenFeature::SDK::Provider::ErrorCode::PARSE_ERROR,
          "TYPE_MISMATCH" => OpenFeature::SDK::Provider::ErrorCode::TYPE_MISMATCH,
          "TARGETING_KEY_MISSING" => OpenFeature::SDK::Provider::ErrorCode::TARGETING_KEY_MISSING,
          "INVALID_CONTEXT" => OpenFeature::SDK::Provider::ErrorCode::INVALID_CONTEXT,
          "GENERAL" => OpenFeature::SDK::Provider::ErrorCode::GENERAL
        }
        error_code_map[error_code_str] || OpenFeature::SDK::Provider::ErrorCode::GENERAL
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
