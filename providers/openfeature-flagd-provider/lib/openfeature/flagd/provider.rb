# frozen_string_literal: true

require_relative "provider/configuration"
require_relative "provider/client"

module OpenFeature
  module FlagD
    module Provider
      class << self
        def client
          @client ||= Client.new(configuration)
        end

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
          @configuration ||= Configuration.new
        end

        def configure(&block)
          return unless block_given?

          block.call(configuration)
        end
      end
    end
  end
end
