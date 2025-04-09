# frozen_string_literal: true

require "flipt_client"
require "open_feature/sdk"

module OpenFeature
  module Flipt
    class Provider
      PROVIDER_NAME = "Flipt Provider"

      # @param namespace [String] Namespace to use when fetching flags.
      # @param options [Hash] Options to pass to the Flipt client.
      def initialize(namespace: "default", options: {})
        @namespace = namespace
        @options = options
      end

      def metadata
        @_metadata ||= SDK::Provider::ProviderMetadata.new(name: PROVIDER_NAME).freeze
      end

      def fetch_boolean_value(flag_key:, default_value:, evaluation_context: nil)
        fetch_value(
          flag_key: flag_key,
          default_value: default_value,
          evaluation_context: evaluation_context,
          evaluation_method: :evaluate_boolean,
          result_key: "enabled"
        )
      end

      def fetch_string_value(flag_key:, default_value:, evaluation_context: nil)
        fetch_value(
          flag_key: flag_key,
          default_value: default_value,
          evaluation_context: evaluation_context,
          evaluation_method: :evaluate_variant,
          result_key: "variant_key"
        )
      end

      def fetch_number_value(flag_key:, default_value:, evaluation_context: nil)
        fetch_numeric_value(flag_key:, default_value:, evaluation_context:, allowed_types: [Numeric])
      end

      def fetch_integer_value(flag_key:, default_value:, evaluation_context: nil)
        fetch_numeric_value(flag_key:, default_value:, evaluation_context:, allowed_types: [Integer])
      end

      def fetch_float_value(flag_key:, default_value:, evaluation_context: nil)
        fetch_numeric_value(flag_key:, default_value:, evaluation_context:, allowed_types: [Float])
      end

      def fetch_object_value(flag_key:, default_value:, evaluation_context: nil)
        result = fetch_value(
          flag_key: flag_key,
          default_value: default_value,
          evaluation_context: evaluation_context,
          evaluation_method: :evaluate_variant,
          result_key: "variant_key"
        )

        unless result.value.is_a?(Hash)
          begin
            result.value = JSON.parse(result.value)
          rescue JSON::ParserError, TypeError
            return OpenFeature::SDK::Provider::ResolutionDetails.new(
              value: default_value,
              error_message: "Could not parse '#{result.value}' as JSON",
              reason: OpenFeature::SDK::Provider::Reason::ERROR
            )
          end
        end
        result
      end

      private

      def client
        @_client ||= ::Flipt::EvaluationClient.new(@namespace, @options)
      end

      def fetch_value(flag_key:, default_value:, evaluation_context:, evaluation_method:, result_key:)
        transformed_eval_context = transform_context(evaluation_context)

        begin
          response = client.send(evaluation_method, {
            flag_key: flag_key,
            entity_id: evaluation_context&.fetch("targeting_key", nil) || "default",
            context: transformed_eval_context
          })

          if %w[FLAG_DISABLED_EVALUATION_REASON].include?(response["result"]["reason"])
            OpenFeature::SDK::Provider::ResolutionDetails.new(
              value: default_value,
              reason: OpenFeature::SDK::Provider::Reason::DISABLED
            )
          elsif %w[DEFAULT_EVALUATION_REASON MATCH_EVALUATION_REASON].include?(response["result"]["reason"])
            OpenFeature::SDK::Provider::ResolutionDetails.new(
              value: response["result"][result_key],
              reason: OpenFeature::SDK::Provider::Reason::TARGETING_MATCH
            )
          elsif %w[UNKNOWN_EVALUATION_REASON].include?(response["result"]["reason"])
            OpenFeature::SDK::Provider::ResolutionDetails.new(
              value: default_value,
              reason: OpenFeature::SDK::Provider::Reason::UNKNOWN
            )
          else
            OpenFeature::SDK::Provider::ResolutionDetails.new(
              value: default_value,
              reason: OpenFeature::SDK::Provider::Reason::DEFAULT
            )
          end
        rescue => e
          OpenFeature::SDK::Provider::ResolutionDetails.new(
            value: default_value,
            error_message: e.message,
            reason: OpenFeature::SDK::Provider::Reason::ERROR
          )
        end
      end

      def fetch_numeric_value(flag_key:, default_value:, evaluation_context:, allowed_types:)
        result = fetch_value(
          flag_key: flag_key,
          default_value: default_value,
          evaluation_context: evaluation_context,
          evaluation_method: :evaluate_variant,
          result_key: "variant_key"
        )

        unless result.value.is_a?(Numeric)
          begin
            parsed_value = Float(result.value)
            # Only convert to integer if it's a whole number and allowed_types is [Integer]
            result.value = if allowed_types == [Integer] && parsed_value.to_i == parsed_value
              parsed_value.to_i
            else
              parsed_value
            end
          rescue ArgumentError, TypeError
            return OpenFeature::SDK::Provider::ResolutionDetails.new(
              value: default_value,
              error_message: "Could not convert '#{result.value}' to #{allowed_types.first.name.downcase}",
              reason: OpenFeature::SDK::Provider::Reason::ERROR
            )
          end
        end

        unless allowed_types.any? { |type| result.value.is_a?(type) }
          return OpenFeature::SDK::Provider::ResolutionDetails.new(
            value: default_value,
            error_message: "Value '#{result.value}' is not a #{allowed_types.first.name.downcase}",
            reason: OpenFeature::SDK::Provider::Reason::ERROR
          )
        end

        result
      end

      def transform_context(context)
        eval_context = {}
        context&.each do |key, value|
          next if key == "targeting_key"

          eval_context[key] = value.to_s
        end
        eval_context
      end
    end
  end
end
