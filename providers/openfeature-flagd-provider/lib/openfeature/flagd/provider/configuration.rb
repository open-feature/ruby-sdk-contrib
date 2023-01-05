# frozen_string_literal: true

module OpenFeature
  module FlagD
    module Provider
      # Represents the configuration object for the FlagD provider,
      # This class is not meant to be interacted with directly but instead through the
      # <tt>OpenFeature::FlagD::Provider.configure</tt> method
      class Configuration
        attr_accessor :host, :port, :tls

        ENVIRONMENT_CONFIG_NAME = {
          host: "FLAGD_HOST",
          port: "FLAGD_PORT",
          tls: "FLAGD_TLS"
        }.freeze

        def merge(other_configuration)
          return self if other_configuration.nil?

          @host = other_configuration.host if !other_configuration.host.nil? && @host.nil?
          @port = other_configuration.port if !other_configuration.port.nil? && @port.nil?
          @tls = other_configuration.tls if !other_configuration.tls.nil? && @tls.nil?
          self
        end

        def self.environment_variables_config
          configuration = Configuration.new
          unless ENV[ENVIRONMENT_CONFIG_NAME[:host]].nil?
            configuration.host = ENV.fetch(ENVIRONMENT_CONFIG_NAME[:host],
                                           nil)
          end
          unless ENV[ENVIRONMENT_CONFIG_NAME[:port]].nil?
            configuration.port = ENV.fetch(ENVIRONMENT_CONFIG_NAME[:port],
                                           nil)
          end
          unless ENV[ENVIRONMENT_CONFIG_NAME[:tls]].nil?
            configuration.tls = ENV.fetch(ENVIRONMENT_CONFIG_NAME[:tls],
                                          nil) == "true"
          end

          configuration
        end

        def self.default_config
          configuration = Configuration.new
          configuration.host = "localhost"
          configuration.port = 8013
          configuration.tls = false
          configuration
        end
      end
    end
  end
end
