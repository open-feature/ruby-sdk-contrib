# frozen_string_literal: true

require "net/http"
require "json"
require "open_feature/sdk"
require_relative "../error/errors"
require_relative "../model/ofrep_api_response"

module OpenFeature
  module GoFeatureFlag
    module Client
      class Common
        def initialize(endpoint: nil, custom_headers: nil)
          raise "This should be overwritten by implementations"
        end

        def evaluate_ofrep_api(flag_key:, evaluation_context:)
          raise "This should be overwritten by implementations"
        end

        private

        def headers
          {"Content-Type" => "application/json"}.merge(@custom_headers || {})
        end

        def check_retry_after
          lock = (@retry_lock ||= Mutex.new)
          lock.synchronize do
            return if @retry_after.nil?
            if Time.now < @retry_after
              raise OpenFeature::GoFeatureFlag::RateLimited.new(nil)
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
            next_retry_time =
              if /^\d+$/.match?(retry_after)
                # Retry-After is in seconds
                Time.now + Integer(retry_after)
              else
                # Retry-After is an HTTP-date
                Time.httpdate(retry_after)
              end
            # Protect updates and never shorten an existing backoff window
            lock = (@retry_lock ||= Mutex.new)
            lock.synchronize do
              @retry_after = [@retry_after, next_retry_time].compact.max
            end
          rescue ArgumentError
            # ignore invalid Retry-After header
            nil
          end
        end
      end
    end
  end
end
