# frozen_string_literal: true

require "grpc"

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
      # * <tt>resolve_boolean_value(flag_key:, default_value:, context: nil)</tt>
      #   manner; <tt>client.resolve_boolean(flag_key: 'boolean-flag', default_value: false)</tt>
      #
      # * <tt>resolve_integer_value(flag_key:, default_value:, context: nil)</tt>
      #   manner; <tt>client.resolve_integer_value(flag_key: 'integer-flag', default_value: 2)</tt>
      #
      # * <tt>resolve_float_value(flag_key:, default_value:, context: nil)</tt>
      #   manner; <tt>client.resolve_float_value(flag_key: 'float-flag', default_value: 2.0)</tt>
      #
      # * <tt>resolve_string_value(flag_key:, default_value:, context: nil)</tt>
      #   manner; <tt>client.resolve_string_value(flag_key: 'string-flag', default_value: 'some-default-value')</tt>
      #
      # * <tt>resolve_object_value(flag_key:, default_value:, context: nil)</tt>
      #   manner; <tt>client.resolve_object_value(flag_key: 'flag', default_value: { default_value: 'value'})</tt>
      class Client
        PROVIDER_NAME = "flagd Provider"

        attr_reader :metadata

        def initialize(configuration: nil)
          @metadata = Metadata.new(PROVIDER_NAME)
          @grpc_client = grpc_client(configuration)
        end


        def resolve_boolean_value(flag_key:, default_value:, context: nil)
          request = Grpc::ResolveBooleanRequest.new(flag_key: flag_key)
          process_request { @grpc_client.resolve_boolean(request) }
        end

        def resolve_integer_value(flag_key:, default_value:, context: nil)
          request = Grpc::ResolveIntRequest.new(flag_key: flag_key)
          process_request { @grpc_client.resolve_int(request) }
        end

        def resolve_float_value(flag_key:, default_value:, context: nil)
          request = Grpc::ResolveFloatRequest.new(flag_key: flag_key)
          process_request { @grpc_client.resolve_float(request) }
        end

        def resolve_string_value(flag_key:, default_value:, context: nil)
          request = Grpc::ResolveStringRequest.new(flag_key: flag_key)
          process_request { @grpc_client.resolve_string(request) }
        end

        def resolve_object_value(flag_key:, default_value:, context: nil)
          request = Grpc::ResolveObjectRequest.new(flag_key: flag_key)
          process_request { @grpc_client.resolve_object(request) }
        end

        private

        Metadata = Struct.new("Metadata", :name)
        ResolutionDetails = Struct.new("ResolutionDetails", :error_code, :error_message, :reason, :value, :variant)

        def process_request(&block)
          response = block.call
          ResolutionDetails.new(nil, nil, response.reason, response.value, response.variant).to_h
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

        def error_response(error_code, error_message)
          ResolutionDetails.new(error_code, error_message, "ERROR", nil, nil).to_h
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
