# frozen_string_literal: true

module OpenFeature
  module Optimizely
    class Configuration
      attr_reader :sdk_key, :optimizely_client, :decide_options

      def initialize(sdk_key: nil, optimizely_client: nil, decide_options: [])
        validate_mutual_exclusivity(sdk_key, optimizely_client)

        @sdk_key = sdk_key
        @optimizely_client = optimizely_client
        @decide_options = decide_options
      end

      private

      def validate_mutual_exclusivity(sdk_key, optimizely_client)
        if sdk_key.nil? && optimizely_client.nil?
          raise ArgumentError, "Either sdk_key or optimizely_client must be provided"
        end

        if sdk_key && optimizely_client
          raise ArgumentError, "Only one of sdk_key or optimizely_client can be provided, not both"
        end

        if sdk_key && sdk_key.to_s.strip.empty?
          raise ArgumentError, "sdk_key cannot be empty"
        end
      end
    end
  end
end
