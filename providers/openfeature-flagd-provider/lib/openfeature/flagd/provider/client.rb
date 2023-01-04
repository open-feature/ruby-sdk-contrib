# frozen_string_literal: true

require_relative "schema/v1/schema_services_pb"
require_relative "configuration"

module OpenFeature
  module FlagD
    module Provider
      # Client represents a wrapper for the GRPC stub that allows for resolution of boolean, string, number, and object
      # values. The implementation follows the details specified in https://docs.openfeature.dev/docs/specification/sections/providers
      #
      #
      # Within the Client instance, the following methods are available:
      #
      # * <tt>resolve_boolean_value(flag_key:, default_value:, context: nil)</tt> -
      #   Resolves the boolean value of the flag_key
      #   manner; <tt>client.resolve_boolean(flag_key: 'boolean-flag', default_value: false)</tt>
      #
      # * <tt>resolve_integer_value(flag_key:, default_value:, context: nil)</tt> - Resolves the
      #   manner; <tt>client.resolve_boolean = File.read('path/to/filename.png')</tt>

      # * <tt>resolve_integer_value</tt> - Allows you to specify any header field in your email such
      #   as <tt>headers['X-No-Spam'] = 'True'</tt>. Note that declaring a header multiple times
      #   will add many fields of the same name. Read #headers doc for more information.
      #
      class Client
        attr_reader :metadata

        def initialize(configuration: nil)
          @configuration = Configuration.default_config
                                        .merge(Configuration.environment_variables_config)
                                        .merge(configuration)
          @metadata = Metadata.new(PROVIDER_NAME).freeze
          @grpc_client = Grpc::Service::Stub.new(
            "#{@configuration.host}:#{@configuration.port}",
            :this_channel_is_insecure
          ).freeze
        end

        PROVIDER_NAME = "Flagd Provider"
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
      end
    end
  end
end
