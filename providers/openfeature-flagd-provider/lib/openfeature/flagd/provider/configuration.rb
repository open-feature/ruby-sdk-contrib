# frozen_string_literal: true

module OpenFeature
  module FlagD
    module Provider
      # Represents the configuration object for the FlagD provider,
      # and <tt>Context</tt> are configured.
      # This class is not meant to be interacted with directly but instead through the <tt>OpenFeature::SDK.configure</tt>
      # method
      class Configuration
        attr_accessor :host, :port, :tls, :socket_path

        def merge(other_configuration)
          return self if other_configuration.nil?

          @host = other_configuration.host unless other_configuration.host.nil?
          @port = other_configuration.port unless other_configuration.port.nil?
          @tls = other_configuration.tls unless other_configuration.tls.nil?
          @socket_path = other_configuration.socket_path unless other_configuration.socket_path.nil?
          self
        end

        def self.environment_variables_config
          configuration = Configuration.new
          configuration.host = ENV.fetch("FLAGD_HOST", nil) unless ENV["FLAG_HOST"].nil?
          configuration.port = ENV["FLAGD_PORT"] unless ENV["FLAGD_PORT"].nil?
          configuration.tls = ENV["FLAGD_TLS"] == "true" unless ENV["FLAGD_TLS"].nil?
          configuration.socket_path = ENV["FLAGD_SOCKET_PATH"] unless ENV["FLAGD_SOCKET_PATH"].nil?
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
