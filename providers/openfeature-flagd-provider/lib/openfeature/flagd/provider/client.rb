# frozen_string_literal: true

require "grpc"
require 'google/protobuf/well_known_types'

require_relative "schema/v1/schema_services_pb"
require_relative "configuration"

module OpenFeature
  module FlagD
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
          @metadata = Metadata.new(PROVIDER_NAME)
          @grpc_client = grpc_client(configuration)
        end

        def fetch_boolean_value(flag_key:, default_value:, evaluation_context: nil)
          request = Grpc::ResolveBooleanRequest.new(flag_key: flag_key, context: prepare_evaluation_context(evaluation_context))
          process_request { @grpc_client.resolve_boolean(request) }
        end

        def fetch_number_value(flag_key:, default_value:, evaluation_context: nil)
          case default_value
          when Integer
            fetch_integer_value(flag_key: flag_key, default_value: default_value, evaluation_context: evaluation_context)
          when Float
            fetch_float_value(flag_key: flag_key, default_value: default_value, evaluation_context: evaluation_context)
          end
        end

        def fetch_integer_value(flag_key:, default_value:, evaluation_context: nil)
          request = Grpc::ResolveIntRequest.new(flag_key: flag_key, context: prepare_evaluation_context(evaluation_context))
          process_request { @grpc_client.resolve_int(request) }
        end

        def fetch_float_value(flag_key:, default_value:, evaluation_context: nil)
          request = Grpc::ResolveFloatRequest.new(flag_key: flag_key, context: prepare_evaluation_context(evaluation_context))
          process_request { @grpc_client.resolve_float(request)  }
        end

        def fetch_string_value(flag_key:, default_value:, evaluation_context: nil)
          request = Grpc::ResolveStringRequest.new(flag_key: flag_key, context: prepare_evaluation_context(evaluation_context))
          process_request { @grpc_client.resolve_string(request) }
        end

        def fetch_object_value(flag_key:, default_value:, evaluation_context: nil)
          request = Grpc::ResolveObjectRequest.new(flag_key: flag_key, context: prepare_evaluation_context(evaluation_context))
          process_request { @grpc_client.resolve_object(request) }
        end

        private

        Metadata = Struct.new("Metadata", :name)
        ResolutionDetails = Struct.new("ResolutionDetails", :error_code, :error_message, :reason, :value, :variant)

        def process_request(&block)
          response = block.call
          ResolutionDetails.new(nil, nil, response.reason, response.value, response.variant)
        rescue GRPC::NotFound => e
          error_response("FLAG_NOT_FOUND", e.message)
        rescue GRPC::InvalidArgument => e
          error_response("TYPE_MISMATCH", e.message)
        rescue GRPC::Unavailable => e
          error_response("FLAG_NOT_FOUND", e.message)
        rescue GRPC::DataLoss => e
          error_response("PARSE_ERROR", e.message)
        rescue StandardError => e
          error_response("GENERAL", e.message)
        end

        def prepare_evaluation_context(evaluation_context)
          return nil unless evaluation_context

          fields = evaluation_context.fields
          fields["targetingKey"] = fields.delete(:targeting_key)
          Google::Protobuf::Struct.from_hash(fields)
        end

        def error_response(error_code, error_message)
          ResolutionDetails.new(error_code, error_message, "ERROR", nil, nil)
        end

        def grpc_client(configuration)
          options = :this_channel_is_insecure
          if configuration.tls
            options = GRPC::Core::ChannelCredentials.new(
              configuration.root_cert_path
            )
          end

          Grpc::Service::Stub.new(server_address(configuration), options).freeze
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
