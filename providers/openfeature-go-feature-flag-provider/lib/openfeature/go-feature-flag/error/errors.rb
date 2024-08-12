# Define a custom error class
require "open_feature/sdk/provider/error_code"

module OpenFeature
  module GoFeatureFlag
    class FlagNotFoundError < StandardError
      attr_reader :response, :error_code, :error_message

      def initialize(response, flag_key)
        error_message = "Flag not found: #{flag_key}"
        @response = response
        @error_code = SDK::Provider::ErrorCode::FLAG_NOT_FOUND
        @error_message = error_message
        super(error_message)
      end
    end

    class InternalServerError < StandardError
      attr_reader :response, :error_code, :error_message

      def initialize(response)
        error_message = "Internal Server Error"
        @response = response
        @error_code = SDK::Provider::ErrorCode::GENERAL
        @error_message = error_message
        super(error_message)
      end
    end

    class InvalidOptionError < StandardError
      attr_reader :error_code, :error_message

      def initialize(error_code, error_message)
        @error_code = error_code
        @error_message = error_message
        super(error_message)
      end
    end

    class UnauthorizedError < StandardError
      attr_reader :response, :error_code, :error_message

      def initialize(response)
        error_message = "unauthorized"
        @response = response
        @error_code = SDK::Provider::ErrorCode::GENERAL
        @error_message = error_message
        super(error_message)
      end
    end

    class ParseError < StandardError
      attr_reader :response, :error_code, :error_message

      def initialize(response)
        error_message = "Parse error"
        @response = response
        @error_code = SDK::Provider::ErrorCode::PARSE_ERROR
        @error_message = error_message
        super(error_message)
      end
    end

    class RateLimited < StandardError
      attr_reader :response, :error_code, :error_message

      def initialize(response)
        error_message = response.nil? ? "Rate limited" : "Rate limited: " + response["Retry-After"].to_s
        @response = response
        @error_code = SDK::Provider::ErrorCode::GENERAL
        @error_message = error_message
        super(error_message)
      end
    end
  end
end
