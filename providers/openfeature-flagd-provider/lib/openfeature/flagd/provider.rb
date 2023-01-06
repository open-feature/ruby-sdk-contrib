# frozen_string_literal: true

require "grpc"

require_relative "provider/configuration"
require_relative "provider/client"

module OpenFeature
  module FlagD
    # Provider represents the entry point for interacting with the FlagD provider
    # values. The implementation follows the details specified in https://docs.openfeature.dev/docs/specification/sections/providers
    #
    # Provider contains functionality to configure the GRPC connection via
    #
    #   OpenFeature::FlagD::Provider.configure do |config|
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
          @configuration ||= explicit_configuration
                             .merge(Configuration.environment_variables_config)
                             .merge(Configuration.default_config)
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
          @client ||= Client.new(configuration:)
        end
      end
    end
  end
end
