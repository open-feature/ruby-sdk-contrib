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
        attr_reader :metadata

        def initialize(configuration: nil)
          @configuration = configuration.freeze
          @metadata = Metadata.new(PROVIDER_NAME).freeze

          @grpc_client = build_client(configuration)
        end

        PROVIDER_NAME = "flagd Provider"
        TYPE_RESOLVER_MAPPER = {
          boolean: Grpc::ResolveBooleanRequest,
          integer: Grpc::ResolveIntRequest,
          float: Grpc::ResolveFloatRequest,
          string: Grpc::ResolveStringRequest,
          object: Grpc::ResolveObjectRequest
        }.freeze

        TYPE_RESOLVER_MAPPER.each_pair do |type, resolver|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def resolve_#{type}_value(flag_key:, default_value:, context: nil)
              request = #{resolver}.new(flag_key: flag_key)
              response = @grpc_client.resolve_#{type}(request)
              ResolutionDetails.new(nil, nil, response.reason, response.value, response.variant).to_h.freeze
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
          RUBY
        end

        private

        Metadata = Struct.new("Metadata", :name)
        ResolutionDetails = Struct.new("ResolutionDetails", :error_code, :error_message, :reason, :value, :variant)

        def error_response(error_code, error_message)
          ResolutionDetails.new(error_code, error_message, "ERROR", nil, nil).to_h.freeze
        end

        def grpc_client(configuration)
          return @grpc_client unless defined?(@grpc_client)
          
          options = :this_channel_is_insecure
          if configuration.tls
            options = GRPC::Core::ChannelCredentials.new(
              configuration.root_certs
            )
          end
          @grpc_client = Grpc::Service::Stub.new(build_server_address(configuration), options).freeze
        end

        def server_address
          @server_address ||= if @configuration.unix_socket_path
            "unix://#{configuration.unix_socket_path}"
          else
            "#{@configuration.host}:#{@configuration.port}"
          end
        end
      end
    end
  end
end
