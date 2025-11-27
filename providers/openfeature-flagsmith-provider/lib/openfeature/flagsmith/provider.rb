# frozen_string_literal: true

require "open_feature/sdk"
require "flagsmith"
require "json"
require_relative "options"
require_relative "error/errors"

module OpenFeature
  module Flagsmith
    # OpenFeature provider for Flagsmith
    class Provider
      PROVIDER_NAME = "Flagsmith Provider"
      attr_reader :metadata, :options

      def initialize(options:)
        @metadata = SDK::Provider::ProviderMetadata.new(name: PROVIDER_NAME)
        @options = options
        @flagsmith_client = nil
      end

      def init
        # Initialize Flagsmith client
        @flagsmith_client = create_flagsmith_client
      end

      def shutdown
        # Cleanup Flagsmith client resources
        # Note: Flagsmith Ruby SDK doesn't require explicit cleanup as of version 4.3
        # If future versions add cleanup methods, they should be called here
        @flagsmith_client = nil
      end

      def fetch_boolean_value(flag_key:, default_value:, evaluation_context: nil)
        evaluate_boolean(flag_key, default_value, evaluation_context)
      end

      def fetch_string_value(flag_key:, default_value:, evaluation_context: nil)
        evaluate_value(flag_key, default_value, evaluation_context, [String])
      end

      def fetch_number_value(flag_key:, default_value:, evaluation_context: nil)
        evaluate_value(flag_key, default_value, evaluation_context, [Integer, Float, Numeric])
      end

      def fetch_integer_value(flag_key:, default_value:, evaluation_context: nil)
        evaluate_value(flag_key, default_value, evaluation_context, [Integer])
      end

      def fetch_float_value(flag_key:, default_value:, evaluation_context: nil)
        evaluate_value(flag_key, default_value, evaluation_context, [Float])
      end

      def fetch_object_value(flag_key:, default_value:, evaluation_context: nil)
        evaluate_value(flag_key, default_value, evaluation_context, [Hash, Array])
      end

      private

      def create_flagsmith_client
        ::Flagsmith::Client.new(
          environment_key: @options.environment_key,
          api_url: @options.api_url,
          enable_local_evaluation: @options.local_evaluation?,
          request_timeout_seconds: @options.request_timeout_seconds,
          enable_analytics: @options.analytics_enabled?,
          environment_refresh_interval_seconds: @options.environment_refresh_interval_seconds
        )
      rescue => e
        raise ProviderNotReadyError, "Failed to create Flagsmith client: #{e.class}: #{e.message}"
      end

      def evaluate_boolean(flag_key, default_value, evaluation_context)
        return provider_not_ready_result(default_value) if @flagsmith_client.nil?
        return invalid_flag_key_result(default_value) if flag_key.nil? || flag_key.to_s.empty?

        flags = get_flags(evaluation_context)
        value = flags.is_feature_enabled(flag_key)

        success_result(value, evaluation_context)
      rescue FlagsmithError => e
        error_result(default_value, e.error_code, e.error_message)
      rescue => e
        error_result(default_value, SDK::Provider::ErrorCode::GENERAL, "Unexpected error: #{e.class}: #{e.message}")
      end

      def evaluate_value(flag_key, default_value, evaluation_context, allowed_type_classes)
        return provider_not_ready_result(default_value) if @flagsmith_client.nil?
        return invalid_flag_key_result(default_value) if flag_key.nil? || flag_key.to_s.empty?

        flags = get_flags(evaluation_context)
        found_flag = flags.all_flags.find { |f| f.feature_name == flag_key }

        return flag_not_found_result(default_value, flag_key) if found_flag.nil?
        return flag_disabled_result(default_value, flag_key) unless found_flag.enabled

        raw_value = found_flag.value
        value = if [Hash, Array].any? { |klass| allowed_type_classes.include?(klass) }
                  parse_json_value(raw_value)
                elsif [Integer, Float, Numeric].any? { |klass| allowed_type_classes.include?(klass) }
                  parse_numeric_value(raw_value, allowed_type_classes)
                else
                  raw_value
                end

        return type_mismatch_result(default_value, value, allowed_type_classes) unless type_matches?(value, allowed_type_classes)

        success_result(value, evaluation_context)
      rescue FlagsmithError => e
        error_result(default_value, e.error_code, e.error_message)
      rescue => e
        error_result(default_value, SDK::Provider::ErrorCode::GENERAL, "Unexpected error: #{e.class}: #{e.message}")
      end

      def provider_not_ready_result(default_value)
        SDK::Provider::ResolutionDetails.new(
          value: default_value,
          reason: SDK::Provider::Reason::ERROR,
          error_code: SDK::Provider::ErrorCode::PROVIDER_NOT_READY,
          error_message: "Provider not initialized. Call init() first."
        )
      end

      def invalid_flag_key_result(default_value)
        SDK::Provider::ResolutionDetails.new(
          value: default_value,
          reason: SDK::Provider::Reason::DEFAULT,
          error_code: SDK::Provider::ErrorCode::FLAG_NOT_FOUND,
          error_message: "Flag key cannot be empty or nil"
        )
      end

      def flag_not_found_result(default_value, flag_key)
        SDK::Provider::ResolutionDetails.new(
          value: default_value,
          reason: SDK::Provider::Reason::DEFAULT,
          error_code: SDK::Provider::ErrorCode::FLAG_NOT_FOUND,
          error_message: "Flag '#{flag_key}' not found"
        )
      end

      def flag_disabled_result(default_value, flag_key)
        SDK::Provider::ResolutionDetails.new(
          value: default_value,
          reason: SDK::Provider::Reason::DISABLED,
          error_message: "Flag '#{flag_key}' is disabled"
        )
      end

      def type_mismatch_result(default_value, value, allowed_type_classes)
        SDK::Provider::ResolutionDetails.new(
          value: default_value,
          reason: SDK::Provider::Reason::ERROR,
          error_code: SDK::Provider::ErrorCode::TYPE_MISMATCH,
          error_message: "Expected type #{allowed_type_classes}, got #{value.class}"
        )
      end

      def error_result(default_value, error_code, error_message)
        SDK::Provider::ResolutionDetails.new(
          value: default_value,
          reason: SDK::Provider::Reason::ERROR,
          error_code: error_code,
          error_message: error_message
        )
      end

      def success_result(value, evaluation_context)
        SDK::Provider::ResolutionDetails.new(
          value: value,
          reason: determine_reason(evaluation_context),
          variant: nil,
          flag_metadata: {}
        )
      end

      def get_flags(evaluation_context)
        raise ProviderNotReadyError, "Flagsmith client not initialized" if @flagsmith_client.nil?

        if evaluation_context.nil?
          return @flagsmith_client.get_environment_flags
        end

        targeting_key = evaluation_context.targeting_key
        if targeting_key.nil? || targeting_key.to_s.strip.empty?
          @flagsmith_client.get_environment_flags
        else
          traits = evaluation_context.fields.transform_keys(&:to_sym).reject { |k, _v| k == :targeting_key }
          @flagsmith_client.get_identity_flags(targeting_key.to_s, **traits)
        end
      rescue => e
        raise FlagsmithClientError, "#{e.class}: #{e.message}"
      end

      def parse_json_value(value)
        return value if value.is_a?(Hash) || value.is_a?(Array)
        return nil if value.nil?

        JSON.parse(value.to_s)
      rescue JSON::ParserError => e
        raise ParseError, e.message
      end

      def parse_numeric_value(value, allowed_type_classes)
        # If already the right type, return it
        return value if allowed_type_classes.any? { |klass| value.is_a?(klass) }
        return nil if value.nil?

        # Try to parse string to numeric
        if value.is_a?(String)
          if allowed_type_classes.include?(Numeric)
            # For Numeric, try Integer first, then Float
            begin
              return Integer(value)
            rescue ArgumentError, TypeError
              return Float(value)
            end
          elsif allowed_type_classes.include?(Integer)
            return Integer(value)
          elsif allowed_type_classes.include?(Float)
            return Float(value)
          end
        end

        # Safe numeric type conversions (following Flipt provider pattern)
        if value.is_a?(Numeric)
          # Integer → Float: always safe (no precision loss)
          if value.is_a?(Integer) && allowed_type_classes == [Float]
            return value.to_f
          end

          # Float → Integer: only if it's a whole number (prevents data loss)
          # Example: 3.0 → 3 (OK), but 3.99 → fails type check (ERROR)
          if value.is_a?(Float) && allowed_type_classes == [Integer]
            return value.to_i if value.to_i == value
          end

          # For generic fetch_number_value (accepts any numeric type), return as-is
          # This handles [Integer, Float, Numeric] case
        end

        value
      rescue ArgumentError, TypeError => e
        raise ParseError, "Cannot convert '#{value}' to numeric type: #{e.message}"
      end

      def type_matches?(value, allowed_type_classes)
        allowed_type_classes.any? { |klass| value.is_a?(klass) }
      end

      def determine_reason(evaluation_context)
        # Use TARGETING_MATCH if we have targeting_key (identity-specific)
        # Use STATIC for environment-level flags
        return SDK::Provider::Reason::STATIC if evaluation_context.nil?

        targeting_key = evaluation_context.targeting_key
        if targeting_key.nil? || targeting_key.to_s.strip.empty?
          SDK::Provider::Reason::STATIC
        else
          SDK::Provider::Reason::TARGETING_MATCH
        end
      end
    end
  end
end
