# frozen_string_literal: true

require_relative "provider/version"
require_relative "provider/configuration"

module OpenFeature
  module FlagD
    module Provider
      class << self
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
