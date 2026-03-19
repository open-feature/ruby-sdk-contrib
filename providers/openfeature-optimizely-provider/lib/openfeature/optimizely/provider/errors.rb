# frozen_string_literal: true

require "open_feature/sdk/provider/error_code"

module OpenFeature
  module Optimizely
    class OptimizelyProviderError < StandardError
      attr_reader :error_code, :error_message

      def initialize(error_code, error_message)
        @error_code = error_code
        @error_message = error_message
        super(error_message)
      end
    end

    class ProviderNotReadyError < OptimizelyProviderError
      def initialize(message = "Optimizely provider is not ready")
        super(
          SDK::Provider::ErrorCode::PROVIDER_NOT_READY,
          message
        )
      end
    end

    class FlagNotFoundError < OptimizelyProviderError
      def initialize(flag_key)
        super(
          SDK::Provider::ErrorCode::FLAG_NOT_FOUND,
          "Flag not found: #{flag_key}"
        )
      end
    end

    class TypeMismatchError < OptimizelyProviderError
      def initialize(expected_types, actual_type)
        super(
          SDK::Provider::ErrorCode::TYPE_MISMATCH,
          "Expected type #{expected_types}, but got #{actual_type}"
        )
      end
    end

    class ParseError < OptimizelyProviderError
      def initialize(message)
        super(
          SDK::Provider::ErrorCode::PARSE_ERROR,
          "Failed to parse value: #{message}"
        )
      end
    end

    class InvalidContextError < OptimizelyProviderError
      def initialize(message)
        super(
          SDK::Provider::ErrorCode::INVALID_CONTEXT,
          "Invalid evaluation context: #{message}"
        )
      end
    end
  end
end
