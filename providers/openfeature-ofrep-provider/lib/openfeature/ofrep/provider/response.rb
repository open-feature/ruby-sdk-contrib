# frozen_string_literal: true

module OpenFeature
  module OFREP
    class Response
      attr_reader :value, :key, :reason, :variant, :error_code, :error_details, :metadata

      def initialize(value:, key:, reason:, variant:, error_code:, error_details:, metadata:)
        @value = value
        @key = key
        @reason = reason
        @variant = variant
        @error_code = error_code
        @error_details = error_details
        @metadata = metadata
      end

      def error?
        !@error_code.nil? && !@error_code.empty?
      end

      def eql?(other)
        return false unless other.is_a?(OpenFeature::OFREP::Response)
        key == other.key &&
          value == other.value &&
          reason == other.reason &&
          variant == other.variant &&
          error_code == other.error_code &&
          error_details == other.error_details &&
          metadata == other.metadata
      end
    end
  end
end
