# frozen_string_literal: true

require_relative "common"
require "faraday/net_http_persistent"

module OpenFeature
  module GoFeatureFlag
    module Client
      class HttpApi < Common
        def initialize(endpoint: nil, custom_headers: nil, instrumentation: nil, timeout: nil)
          @custom_headers = custom_headers
          request_options = {timeout: timeout}
          @faraday_connection = Faraday.new(url: endpoint, headers: headers, request: request_options) do |f|
            f.request :instrumentation, instrumentation if instrumentation
            f.adapter :net_http_persistent do |http|
              http.idle_timeout = 30
            end
          end
        end

        def evaluate_ofrep_api(flag_key:, evaluation_context:)
          check_retry_after
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
      end
    end
  end
end
