# frozen_string_literal: true

require "grpc"
require "google/protobuf/well_known_types"

require_relative "flagd/evaluation/v1/evaluation_services_pb"
require_relative "configuration"

module OpenFeature
  module Flagd
    module Provider
      # Client represents a wrapper for the GRPC stub that allows for resolution of boolean, string, number, and object
      # values. The implementation follows the details specified in https://openfeature.dev/docs/specification/sections/providers
      #
      #
      # The Client provides the following methods and attributes:
      #
      # * <tt>metadata</tt> - Returns the associated provider metadata with the name
      #
      # * <tt>fetch_boolean_value(flag_key:, default_value:, evaluation_context: nil)</tt>
      #   manner; <tt>client.fetch_boolean(flag_key: 'boolean-flag', default_value: false)</tt>
      #
      # * <tt>fetch_integer_value(flag_key:, default_value:, evaluation_context: nil)</tt>
      #   manner; <tt>client.fetch_integer_value(flag_key: 'integer-flag', default_value: 2)</tt>
      #
      # * <tt>fetch_float_value(flag_key:, default_value:, evaluation_context: nil)</tt>
      #   manner; <tt>client.fetch_float_value(flag_key: 'float-flag', default_value: 2.0)</tt>
      #
      # * <tt>fetch_string_value(flag_key:, default_value:, evaluation_context: nil)</tt>
      #   manner; <tt>client.fetch_string_value(flag_key: 'string-flag', default_value: 'some-default-value')</tt>
      #
      # * <tt>fetch_object_value(flag_key:, default_value:, evaluation_context: nil)</tt>
      #   manner; <tt>client.fetch_object_value(flag_key: 'flag', default_value: { default_value: 'value'})</tt>
      class Client
        PROVIDER_NAME = "flagd Provider"

        attr_reader :metadata

        def initialize(configuration: nil)
          @metadata = OpenFeature::SDK::Provider::ProviderMetadata.new(name: PROVIDER_NAME)
          @grpc_client = grpc_client(configuration)
        end

        def fetch_boolean_value(flag_key:, default_value:, evaluation_context: nil)
          request = Grpc::Evaluation::ResolveBooleanRequest.new(flag_key: flag_key, context: prepare_evaluation_context(evaluation_context))
          process_request(default_value) { @grpc_client.resolve_boolean(request) }
        end

        def fetch_number_value(flag_key:, default_value:, evaluation_context: nil)
          raise "fetch_number_value is not supported by flagd"
        end

        def fetch_integer_value(flag_key:, default_value:, evaluation_context: nil)
          request = Grpc::Evaluation::ResolveIntRequest.new(flag_key: flag_key, context: prepare_evaluation_context(evaluation_context))
          process_request(default_value) { @grpc_client.resolve_int(request) }
        end

        def fetch_float_value(flag_key:, default_value:, evaluation_context: nil)
          request = Grpc::Evaluation::ResolveFloatRequest.new(flag_key: flag_key, context: prepare_evaluation_context(evaluation_context))
          process_request(default_value) { @grpc_client.resolve_float(request) }
        end

        def fetch_string_value(flag_key:, default_value:, evaluation_context: nil)
          request = Grpc::Evaluation::ResolveStringRequest.new(flag_key: flag_key, context: prepare_evaluation_context(evaluation_context))
          process_request(default_value) { @grpc_client.resolve_string(request) }
        end

        def fetch_object_value(flag_key:, default_value:, evaluation_context: nil)
          request = Grpc::Evaluation::ResolveObjectRequest.new(flag_key: flag_key, context: prepare_evaluation_context(evaluation_context))
          process_request(default_value) { @grpc_client.resolve_object(request) }
        end

        private

        def process_request(default_value, &block)
          response = block.call
          OpenFeature::SDK::Provider::ResolutionDetails.new(
            value: response.value,
            reason: response.reason,
            variant: response.variant,
            error_code: nil,
            error_message: nil,
            flag_metadata: nil
          )
        rescue GRPC::NotFound => e
          error_response(default_value, "FLAG_NOT_FOUND", e.message)
        rescue GRPC::InvalidArgument => e
          error_response(default_value, "TYPE_MISMATCH", e.message)
        rescue GRPC::Unavailable => e
          error_response(default_value, "FLAG_NOT_FOUND", e.message)
        rescue GRPC::DataLoss => e
          error_response(default_value, "PARSE_ERROR", e.message)
        rescue => e
          error_response(default_value, "GENERAL", e.message)
        end

        def prepare_evaluation_context(evaluation_context)
          return nil unless evaluation_context

          fields = evaluation_context.fields
          fields["targetingKey"] = fields.delete("targeting_key")
          Google::Protobuf::Struct.from_hash(fields)
        end

        def error_response(default_value, error_code, error_message)
          OpenFeature::SDK::Provider::ResolutionDetails.new(
            value: default_value,
            reason: "ERROR",
            variant: nil,
            error_code: error_code,
            error_message: error_message,
            flag_metadata: nil
          )
        end

        def grpc_client(configuration)
          options = :this_channel_is_insecure
          if configuration.tls
            options = GRPC::Core::ChannelCredentials.new(
              configuration.root_cert_path
            )
          end

          Grpc::Evaluation::Service::Stub.new(server_address(configuration), options).freeze
        end

        def server_address(configuration)
          if configuration.unix_socket_path
            "unix://#{configuration.unix_socket_path}"
          else
            "#{configuration.host}:#{configuration.port}"
          end
        end
      end
    end
  end
end
