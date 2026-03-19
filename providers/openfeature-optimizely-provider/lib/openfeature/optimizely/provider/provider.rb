# frozen_string_literal: true

require "open_feature/sdk"
require "optimizely"
require_relative "configuration"
require_relative "errors"

module OpenFeature
  module Optimizely
    class Provider
      PROVIDER_NAME = "Optimizely Provider"
      ALLOWED_STRING_TYPES = [String].freeze
      ALLOWED_NUMBER_TYPES = [Integer, Float, Numeric].freeze
      ALLOWED_INTEGER_TYPES = [Integer].freeze
      ALLOWED_FLOAT_TYPES = [Float].freeze
      ALLOWED_OBJECT_TYPES = [Hash, Array].freeze
      NUMERIC_CLASSES = [Integer, Float, Numeric].freeze
      EXCLUDED_CONTEXT_FIELDS = %w[targeting_key variable_key].freeze
      EMPTY_METADATA = {}.freeze

      attr_reader :metadata, :configuration

      def initialize(configuration:)
        @metadata = SDK::Provider::ProviderMetadata.new(name: PROVIDER_NAME)
        @configuration = configuration
        @optimizely_client = nil
      end

      def init
        @optimizely_client = @configuration.optimizely_client ||
          ::Optimizely::Project.new(sdk_key: @configuration.sdk_key)
      rescue => e
        raise ProviderNotReadyError, "Failed to create Optimizely client: #{e.class}: #{e.message}"
      end

      def shutdown
        @optimizely_client&.close
        @optimizely_client = nil
      end

      def fetch_boolean_value(flag_key:, default_value:, evaluation_context: nil)
        return provider_not_ready_result(default_value) if @optimizely_client.nil?
        return invalid_flag_key_result(default_value) if flag_key.nil? || flag_key.to_s.empty?

        decision = make_decision(flag_key, evaluation_context)
        return flag_not_found_result(default_value, flag_key) if decision.nil?

        success_result(decision.enabled, decision)
      rescue OptimizelyProviderError => e
        error_result(default_value, e.error_code, e.error_message)
      rescue => e
        error_result(default_value, SDK::Provider::ErrorCode::GENERAL, "Unexpected error: #{e.class}: #{e.message}")
      end

      def fetch_string_value(flag_key:, default_value:, evaluation_context: nil)
        evaluate_variable(flag_key, default_value, evaluation_context, ALLOWED_STRING_TYPES)
      end

      def fetch_number_value(flag_key:, default_value:, evaluation_context: nil)
        evaluate_variable(flag_key, default_value, evaluation_context, ALLOWED_NUMBER_TYPES)
      end

      def fetch_integer_value(flag_key:, default_value:, evaluation_context: nil)
        evaluate_variable(flag_key, default_value, evaluation_context, ALLOWED_INTEGER_TYPES)
      end

      def fetch_float_value(flag_key:, default_value:, evaluation_context: nil)
        evaluate_variable(flag_key, default_value, evaluation_context, ALLOWED_FLOAT_TYPES)
      end

      def fetch_object_value(flag_key:, default_value:, evaluation_context: nil)
        evaluate_variable(flag_key, default_value, evaluation_context, ALLOWED_OBJECT_TYPES)
      end

      private

      def evaluate_variable(flag_key, default_value, evaluation_context, allowed_type_classes)
        return provider_not_ready_result(default_value) if @optimizely_client.nil?
        return invalid_flag_key_result(default_value) if flag_key.nil? || flag_key.to_s.empty?

        optimizely_flag_key, variable_key = resolve_keys(flag_key, evaluation_context)
        decision = make_decision(optimizely_flag_key, evaluation_context)
        return flag_not_found_result(default_value, optimizely_flag_key) if decision.nil?
        return flag_disabled_result(default_value, optimizely_flag_key) unless decision.enabled

        value = extract_variable(decision, variable_key, allowed_type_classes)
        value = coerce_value(value, allowed_type_classes)

        return type_mismatch_result(default_value, value, allowed_type_classes) unless type_matches?(value, allowed_type_classes)

        success_result(value, decision)
      rescue OptimizelyProviderError => e
        error_result(default_value, e.error_code, e.error_message)
      rescue => e
        error_result(default_value, SDK::Provider::ErrorCode::GENERAL, "Unexpected error: #{e.class}: #{e.message}")
      end

      def resolve_keys(flag_key, evaluation_context)
        if evaluation_context&.fields&.key?("variable_key")
          variable_key = evaluation_context.fields["variable_key"]
          return [flag_key, variable_key]
        end

        if flag_key.include?(".")
          parts = flag_key.split(".", 2)
          [parts[0], parts[1]]
        else
          [flag_key, nil]
        end
      end

      def make_decision(flag_key, evaluation_context)
        user_id = extract_user_id(evaluation_context)
        attributes = extract_attributes(evaluation_context)

        user_context = @optimizely_client.create_user_context(user_id, attributes)
        return nil if user_context.nil?

        decision = user_context.decide(flag_key, @configuration.decide_options)
        return nil if decision.nil? || !decision.flag_key || decision.flag_key.empty?

        decision
      end

      def extract_user_id(evaluation_context)
        return "anonymous" if evaluation_context.nil?

        targeting_key = evaluation_context.targeting_key
        if targeting_key.nil? || targeting_key.to_s.strip.empty?
          "anonymous"
        else
          targeting_key.to_s
        end
      end

      def extract_attributes(evaluation_context)
        return {} if evaluation_context.nil?

        fields = evaluation_context.fields || {}
        fields.reject { |k, _| EXCLUDED_CONTEXT_FIELDS.include?(k.to_s) }
      end

      def extract_variable(decision, variable_key, allowed_type_classes)
        variables = decision.variables || {}

        if variable_key
          unless variables.key?(variable_key)
            raise FlagNotFoundError, "Variable '#{variable_key}' not found in flag '#{decision.flag_key}'"
          end
          variables[variable_key]
        else
          matching = variables.select { |_, v| type_matches?(v, allowed_type_classes) }

          if matching.empty?
            raise TypeMismatchError.new(allowed_type_classes, variables.values.map(&:class).uniq)
          end

          if matching.size > 1
            raise ParseError, "Ambiguous: multiple variables match type #{allowed_type_classes} in flag '#{decision.flag_key}'. Use dotted notation or variable_key context field."
          end

          matching.values.first
        end
      end

      def coerce_value(value, allowed_type_classes)
        return value if type_matches?(value, allowed_type_classes)

        if NUMERIC_CLASSES.any? { |klass| allowed_type_classes.include?(klass) }
          coerce_numeric(value, allowed_type_classes)
        else
          value
        end
      end

      def coerce_numeric(value, allowed_type_classes)
        return value if allowed_type_classes.any? { |klass| value.is_a?(klass) }

        if value.is_a?(String)
          if allowed_type_classes.include?(Integer)
            return Integer(value)
          elsif allowed_type_classes.include?(Float)
            return Float(value)
          elsif allowed_type_classes.include?(Numeric)
            begin
              return Integer(value)
            rescue ArgumentError, TypeError
              return Float(value)
            end
          end
        end

        if value.is_a?(Integer) && allowed_type_classes == [Float]
          return value.to_f
        end

        if value.is_a?(Float) && allowed_type_classes == [Integer]
          return value.to_i if value.to_i == value
        end

        value
      rescue ArgumentError, TypeError => e
        raise ParseError, "Cannot convert '#{value}' to numeric type: #{e.message}"
      end

      def type_matches?(value, allowed_type_classes)
        allowed_type_classes.any? { |klass| value.is_a?(klass) }
      end

      def determine_reason(decision)
        if decision&.variation_key && !decision.variation_key.empty?
          SDK::Provider::Reason::TARGETING_MATCH
        else
          SDK::Provider::Reason::STATIC
        end
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

      def success_result(value, decision)
        SDK::Provider::ResolutionDetails.new(
          value: value,
          reason: determine_reason(decision),
          variant: decision&.variation_key,
          flag_metadata: build_flag_metadata(decision)
        )
      end

      def build_flag_metadata(decision)
        return EMPTY_METADATA unless decision&.rule_key

        {"rule_key" => decision.rule_key}
      end
    end
  end
end
