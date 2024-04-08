# frozen_string_literal: true

module OpenFeature
  module FlagD
    module Provider
      # Represents the configuration object for the FlagD provider,
      # This class is not meant to be interacted with directly but instead through the
      # <tt>OpenFeature::FlagD::Provider.configure</tt> method
      class Configuration < Struct.new(:host, :port, :tls, :unix_socket_path, :root_cert_path, keyword_init: true)
        ENVIRONMENT_CONFIG_NAME = {
          host: "FLAGD_HOST",
          port: "FLAGD_PORT",
          tls: "FLAGD_TLS",
          unix_socket_path: "FLAGD_SOCKET_PATH",
          root_cert_path: "FLAGD_SERVER_CERT_PATH"
        }.freeze

        class << self
          def default_config
            new(host: "localhost", port: 8013, tls: false, unix_socket_path: nil, root_cert_path: nil)
          end

          def environment_variables_config
            new(
              host: ENV.fetch(ENVIRONMENT_CONFIG_NAME[:host], nil),
              port: ENV[ENVIRONMENT_CONFIG_NAME[:port]].nil? ? nil : Integer(ENV[ENVIRONMENT_CONFIG_NAME[:port]]),
              tls: ENV[ENVIRONMENT_CONFIG_NAME[:tls]].nil? ? nil : ENV.fetch(ENVIRONMENT_CONFIG_NAME[:tls], nil) == "true",
              unix_socket_path: ENV.fetch(ENVIRONMENT_CONFIG_NAME[:unix_socket_path], nil),
              root_cert_path: ENV.fetch(ENVIRONMENT_CONFIG_NAME[:root_cert_path], nil)
            )
          end
        end

        def merge(other_configuration)
          return self if other_configuration.nil?

          self.class.new(**self.to_h.compact.merge(other_configuration.to_h.compact))
        end
      end
    end
  end
end
