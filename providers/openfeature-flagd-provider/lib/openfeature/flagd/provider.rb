# frozen_string_literal: true

require "grpc"

require_relative "provider/configuration"
require_relative "provider/client"

module OpenFeature
  module FlagD
    # Provider represents the entry point for interacting with the FlagD provider
    # values. The implementation follows the details specified in https://openfeature.dev/docs/specification/sections/providers
    #
    # Provider contains functionality to configure the GRPC connection via
    #   flagd_client = OpenFeature::FlagD::Provider.get_client
    #   flagd_client.configure do |config|
    #     config.host = 'localhost'
    #     config.port = 8379
    #     config.tls = false
    #   end
    # The Provider provides the following methods and attributes:
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
    #   manner; <tt>client.resolve_object_value(flag_key: 'object-flag', default_value: { default_value: 'value'})</tt>
    module Provider
      class << self
        def build_client
          ConfiguredClient.new
        end
      end

      class ConfiguredClient
        def method_missing(method_name, *args, **kwargs, &)
          if client.respond_to?(method_name)
            client.send(method_name, *args, **kwargs, &)
          else
            super
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          client.respond_to?(method_name, include_private) || super
        end

        def configuration
          @configuration ||= Configuration.default_config
                             .merge(Configuration.environment_variables_config)
                             .merge(explicit_configuration)
        end

        def configure(&block)
          return unless block_given?

          block.call(explicit_configuration)
        end

        private

        def explicit_configuration
          @explicit_configuration ||= Configuration.new
        end

        def client
          @client ||= Client.new(configuration: configuration)
        end
      end
    end
  end
end
