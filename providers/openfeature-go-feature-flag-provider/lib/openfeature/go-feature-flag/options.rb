# frozen_string_literal: true
require 'uri'

module OpenFeature
  module GoFeatureFlag
    # This class is the configuration class for the GoFeatureFlagProvider
    class Options
      attr_accessor :endpoint, :custom_headers

      def initialize(endpoint: nil, headers: {})
        validate_endpoint(endpoint: endpoint)
        @endpoint = endpoint
        @custom_headers = headers
      end

      private

      def validate_endpoint(endpoint:nil)
        return if endpoint.nil?

        uri = URI.parse(endpoint)
        raise ArgumentError, "Invalid URL for endpoint: #{endpoint}" unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      rescue URI::InvalidURIError
        raise ArgumentError, "Invalid URL for endpoint: #{endpoint}"
      end
    end
  end
end
