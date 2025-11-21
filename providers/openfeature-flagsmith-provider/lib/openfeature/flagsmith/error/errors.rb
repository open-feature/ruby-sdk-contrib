# frozen_string_literal: true

require "open_feature/sdk/provider/error_code"

module OpenFeature
  module Flagsmith
    # Base error class for Flagsmith provider
    class FlagsmithError < StandardError
      attr_reader :error_code, :error_message

      def initialize(error_code, error_message)
        @error_code = error_code
        @error_message = error_message
        super(error_message)
      end
    end

    # Raised when a flag is not found in Flagsmith
    class FlagNotFoundError < FlagsmithError
      def initialize(flag_key)
        super(
          SDK::Provider::ErrorCode::FLAG_NOT_FOUND,
          "Flag not found: #{flag_key}"
        )
      end
    end

    # Raised when there's a type mismatch between expected and actual flag value
    class TypeMismatchError < FlagsmithError
      def initialize(expected_types, actual_type)
        super(
          SDK::Provider::ErrorCode::TYPE_MISMATCH,
          "Expected type #{expected_types}, but got #{actual_type}"
        )
      end
    end

    # Raised when the Flagsmith client is not ready or properly initialized
    class ProviderNotReadyError < FlagsmithError
      def initialize(message = "Flagsmith provider is not ready")
        super(
          SDK::Provider::ErrorCode::PROVIDER_NOT_READY,
          message
        )
      end
    end

    # Raised when there's an error parsing flag values
    class ParseError < FlagsmithError
      def initialize(message)
        super(
          SDK::Provider::ErrorCode::PARSE_ERROR,
          "Failed to parse flag value: #{message}"
        )
      end
    end

    # Raised for general Flagsmith SDK errors
    class FlagsmithClientError < FlagsmithError
      def initialize(message)
        super(
          SDK::Provider::ErrorCode::GENERAL,
          "Flagsmith client error: #{message}"
        )
      end
    end

    # Raised when evaluation context is invalid
    class InvalidContextError < FlagsmithError
      def initialize(message)
        super(
          SDK::Provider::ErrorCode::INVALID_CONTEXT,
          "Invalid evaluation context: #{message}"
        )
      end
    end
  end
end
