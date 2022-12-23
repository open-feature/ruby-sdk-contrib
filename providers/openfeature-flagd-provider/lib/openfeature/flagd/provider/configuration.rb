# frozen_string_literal: true

module OpenFeature
  module FlagD
    module Provider
      # Represents the configuration object for the FlagD provider,
      # and <tt>Context</tt> are configured.
      # This class is not meant to be interacted with directly but instead through the <tt>OpenFeature::SDK.configure</tt>
      # method
      class Configuration
        attr_accessor :host, :port, :tls

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
