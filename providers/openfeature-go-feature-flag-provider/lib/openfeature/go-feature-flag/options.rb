# frozen_string_literal: true

require "uri"

module OpenFeature
  module GoFeatureFlag
    # This class is the configuration class for the GoFeatureFlagProvider
    class Options
      attr_accessor :endpoint, :custom_headers, :exporter_metadata, :instrumentation

      def initialize(endpoint: nil, headers: {}, exporter_metadata: {}, instrumentation: nil)
        validate_endpoint(endpoint: endpoint)
        validate_instrumentation(instrumentation: instrumentation)
        @endpoint = endpoint
        @custom_headers = headers
        @exporter_metadata = exporter_metadata
        @instrumentation = instrumentation
      end

      private

      def validate_endpoint(endpoint: nil)
        return if endpoint.nil?

        uri = URI.parse(endpoint)
        raise ArgumentError, "Invalid URL for endpoint: #{endpoint}" unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      rescue URI::InvalidURIError
        raise ArgumentError, "Invalid URL for endpoint: #{endpoint}"
      end

      def validate_instrumentation(instrumentation: nil)
        return if instrumentation.nil?
        return if instrumentation.is_a?(Hash)

        raise ArgumentError, "Invalid type for instrumentation: #{instrumentation.class}"
      end
    end
  end
end
