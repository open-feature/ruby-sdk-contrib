# frozen_string_literal: true

require "uri"

module OpenFeature
  module Flagsmith
    # Configuration options for the Flagsmith OpenFeature provider
    class Options
      attr_reader :environment_key, :api_url, :enable_local_evaluation,
        :request_timeout_seconds, :enable_analytics,
        :environment_refresh_interval_seconds

      DEFAULT_API_URL = "https://edge.api.flagsmith.com/api/v1/"
      DEFAULT_REQUEST_TIMEOUT = 10
      DEFAULT_REFRESH_INTERVAL = 60

      def initialize(
        environment_key:,
        api_url: DEFAULT_API_URL,
        enable_local_evaluation: false,
        request_timeout_seconds: DEFAULT_REQUEST_TIMEOUT,
        enable_analytics: false,
        environment_refresh_interval_seconds: DEFAULT_REFRESH_INTERVAL
      )
        validate_environment_key(environment_key: environment_key)
        validate_api_url(api_url: api_url)
        validate_timeout(timeout: request_timeout_seconds)
        validate_refresh_interval(interval: environment_refresh_interval_seconds)

        @environment_key = environment_key
        @api_url = api_url
        @enable_local_evaluation = enable_local_evaluation
        @request_timeout_seconds = request_timeout_seconds
        @enable_analytics = enable_analytics
        @environment_refresh_interval_seconds = environment_refresh_interval_seconds
      end

      def local_evaluation?
        @enable_local_evaluation
      end

      def analytics_enabled?
        @enable_analytics
      end

      private

      def validate_environment_key(environment_key: nil)
        if environment_key.nil? || environment_key.to_s.strip.empty?
          raise ArgumentError, "environment_key is required and cannot be empty"
        end
      end

      def validate_api_url(api_url: nil)
        return if api_url.nil?

        uri = URI.parse(api_url)
        unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
          raise ArgumentError, "Invalid URL for api_url: #{api_url}"
        end
      rescue URI::InvalidURIError
        raise ArgumentError, "Invalid URL for api_url: #{api_url}"
      end

      def validate_timeout(timeout: nil)
        return if timeout.nil?

        unless timeout.is_a?(Integer) && timeout.positive?
          raise ArgumentError, "request_timeout_seconds must be a positive integer"
        end
      end

      def validate_refresh_interval(interval: nil)
        return if interval.nil?

        unless interval.is_a?(Integer) && interval.positive?
          raise ArgumentError, "environment_refresh_interval_seconds must be a positive integer"
        end
      end
    end
  end
end
