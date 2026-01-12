# frozen_string_literal: true

require_relative "common"
require_relative "../internal/http_unix"

module OpenFeature
  module GoFeatureFlag
    module Client
      class UnixApi < Common

        def initialize(endpoint: nil, custom_headers: nil, unix_socket_client_factory: nil)
          @custom_headers = custom_headers
          @endpoint = endpoint
          @unix_socket_client_factory = unix_socket_client_factory || ->(ep) { HttpUnix.new(ep) }
        end

        def evaluate_ofrep_api(flag_key:, evaluation_context:)
          check_retry_after
          evaluation_context = OpenFeature::SDK::EvaluationContext.new if evaluation_context.nil?
          # replace targeting_key by targetingKey
          evaluation_context.fields["targetingKey"] = evaluation_context.targeting_key
          evaluation_context.fields.delete("targeting_key")

          response = thread_local_socket.post("/ofrep/v1/evaluate/flags/#{flag_key}", {context: evaluation_context.fields}, headers)

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

        private

        def thread_local_socket
          key = "openfeature_goff_unix_socket_#{object_id}"
          Thread.current[key] ||= @unix_socket_client_factory.call(@endpoint)
        end
      end
    end
  end
end
