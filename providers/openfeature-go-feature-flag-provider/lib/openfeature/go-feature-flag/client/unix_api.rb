# frozen_string_literal: true

require_relative "common"
require_relative "../internal/http_unix"

module OpenFeature
  module GoFeatureFlag
    module Client
      class UnixApi < Common
        attr_accessor :socket

        def initialize(endpoint: nil, custom_headers: nil)
          @custom_headers = custom_headers
          @socket = HttpUnix.new(endpoint)
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

          response = @socket.post("/ofrep/v1/evaluate/flags/#{flag_key}", {context: evaluation_context.fields})

          case response.code
          when "200"
            parse_success_response(response)
          when "400"
            parse_error_response(response)
          when "401", "403"
            raise OpenFeature::GoFeatureFlag::UnauthorizedError.new(response)
          when "404"
            raise OpenFeature::GoFeatureFlag::FlagNotFoundError.new(response, flag_key)
          when "429"
            parse_retry_later_header(response)
            raise OpenFeature::GoFeatureFlag::RateLimited.new(response)
          else
            raise OpenFeature::GoFeatureFlag::InternalServerError.new(response)
          end
        end
      end
    end
  end
end
