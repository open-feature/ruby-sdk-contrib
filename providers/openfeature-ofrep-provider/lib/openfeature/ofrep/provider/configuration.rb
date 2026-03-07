# frozen_string_literal: true

require "uri"

module OpenFeature
  module OFREP
    class Configuration
      attr_reader :base_url, :headers, :timeout

      def initialize(base_url:, headers: {}, timeout: 10)
        validate_base_url(base_url)
        @base_url = base_url
        @headers = headers
        @timeout = timeout
      end

      private

      def validate_base_url(base_url)
        raise ArgumentError, "base_url is required" if base_url.nil? || base_url.empty?

        uri = URI.parse(base_url)
        raise ArgumentError, "Invalid URL for base_url: #{base_url}" unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      rescue URI::InvalidURIError
        raise ArgumentError, "Invalid URL for base_url: #{base_url}"
      end
    end
  end
end
