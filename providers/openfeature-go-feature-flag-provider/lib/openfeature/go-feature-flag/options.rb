# frozen_string_literal: true

require "uri"

module OpenFeature
  module GoFeatureFlag
    # This class is the configuration class for the GoFeatureFlagProvider
    class Options
      attr_accessor :endpoint, :custom_headers, :exporter_metadata, :instrumentation, :type, :timeout

      def initialize(endpoint: nil, headers: {}, exporter_metadata: {}, instrumentation: nil, type: "http", timeout: 1)
        validate_endpoint(endpoint, type)
        validate_instrumentation(instrumentation: instrumentation)
        @type = type
        @endpoint = endpoint
        @custom_headers = headers
        @exporter_metadata = exporter_metadata
        @instrumentation = instrumentation
        @timeout = timeout
      end

      private

      def validate_endpoint(endpoint, type)
        return if endpoint.nil?

        case type
        when "http"
          uri = URI.parse(endpoint)
          raise ArgumentError, "Invalid URL for endpoint: #{endpoint}" unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        when "unix"
          raise ArgumentError, "File not found: #{endpoint}" unless File.exist?(endpoint)
        else
          raise ArgumentError, "Invalid Type: #{type}"
        end
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
