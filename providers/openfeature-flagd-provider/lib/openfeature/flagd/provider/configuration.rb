# frozen_string_literal: true

module OpenFeature
  module FlagD
    module Provider
      # Represents the configuration object for the FlagD provider,
      # This class is not meant to be interacted with directly but instead through the
      # <tt>OpenFeature::FlagD::Provider.configure</tt> method
      class Configuration
        attr_accessor :host, :port, :tls, :unix_socket_path, :root_cert_path

        ENVIRONMENT_CONFIG_NAME = {
          host: "FLAGD_HOST",
          port: "FLAGD_PORT",
          tls: "FLAGD_TLS",
          unix_socket_path: "FLAGD_SOCKET_PATH",
          root_cert_path: "FLAGD_SERVER_CERT_PATH"
        }.freeze

        def merge(other_configuration)
          return self if other_configuration.nil?

          @host = other_configuration.host if !other_configuration.host.nil? && @host.nil?
          @port = other_configuration.port if !other_configuration.port.nil? && @port.nil?
          @tls = other_configuration.tls if !other_configuration.tls.nil? && @tls.nil?
          if !other_configuration.unix_socket_path.nil? && @unix_socket_path.nil?
            @unix_socket_path = other_configuration.unix_socket_path
          end
          if !other_configuration.root_cert_path.nil? && @root_cert.nil?
            @root_cert = File.read(other_configuration.root_cert_path)
          end

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
          unless ENV[ENVIRONMENT_CONFIG_NAME[:unix_socket_path]].nil?
            configuration.unix_socket_path = ENV.fetch(ENVIRONMENT_CONFIG_NAME[:unix_socket_path],
                                                       nil)
          end
          unless ENV[ENVIRONMENT_CONFIG_NAME[:root_cert_path]].nil?
            root_cert_path = ENV.fetch(ENVIRONMENT_CONFIG_NAME[:root_cert_path], nil)
            configuration.root_cert = File.read(root_cert_path)
          end

          configuration
        end

        def self.default_config
          configuration = Configuration.new
          configuration.host = "localhost"
          configuration.port = 8013
          configuration.tls = false
          configuration.unix_socket_path = nil
          configuration.root_cert_path = nil
          configuration
        end
      end
    end
  end
end
