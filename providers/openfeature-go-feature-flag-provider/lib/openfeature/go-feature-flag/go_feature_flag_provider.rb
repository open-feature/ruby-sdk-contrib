# frozen_string_literal: true

module OpenFeature
  module GoFeatureFlag
    # This class is the entry point for the GoFeatureFlagProvider
    class Provider
      PROVIDER_NAME = "GO Feature Flag Provider"
      attr_reader :metadata, :options

      def initialize(options: Options.new)
        @metadata = SDK::Provider::ProviderMetadata.new(name: PROVIDER_NAME)
        @options = options
        @goff_api = GoFeatureFlagApi.new(endpoint: options.endpoint, custom_headers: options.custom_headers)
      end

      def fetch_boolean_value(flag_key:, default_value:, evaluation_context: nil)
        evaluate(flag_key: flag_key, default_value: default_value, evaluation_context: evaluation_context, allowed_classes: [TrueClass, FalseClass])
      end

      def fetch_string_value(flag_key:, default_value:, evaluation_context: nil)
        evaluate(flag_key: flag_key, default_value: default_value, evaluation_context: evaluation_context, allowed_classes: [String])
      end

      def fetch_number_value(flag_key:, default_value:, evaluation_context: nil)
        evaluate(flag_key: flag_key, default_value: default_value, evaluation_context: evaluation_context, allowed_classes: [Integer, Float])
      end

      def fetch_object_value(flag_key:, default_value:, evaluation_context: nil)
        evaluate(flag_key: flag_key, default_value: default_value, evaluation_context: evaluation_context, allowed_classes: [Array, Hash])
      end

      private

      def evaluate(flag_key:, default_value:, allowed_classes:, evaluation_context: nil)
        evaluation_context = OpenFeature::SDK::EvaluationContext.new if evaluation_context.nil?
        validate_parameters(flag_key, evaluation_context)

        # enrich the evaluation context with the exporter_metadata
        @options.exporter_metadata.merge!("openfeature" => true, "provider" => "ruby")
        evaluation_context.fields["gofeatureflag"] = {"exporterMetadata" => @options.exporter_metadata}

        # do a http call to the go feature flag server
        parsed_response = @goff_api.evaluate_ofrep_api(flag_key: flag_key, evaluation_context: evaluation_context)
        parsed_response = OfrepApiResponse unless parsed_response.is_a?(OfrepApiResponse)

        if parsed_response.has_error?
          return SDK::Provider::ResolutionDetails.new(
            value: default_value,
            error_code: parsed_response.error_code,
            error_message: parsed_response.error_details,
            reason: parsed_response.reason
          )
        end

        unless allowed_classes.include?(parsed_response.value.class)
          return SDK::Provider::ResolutionDetails.new(
            value: default_value,
            error_code: SDK::Provider::ErrorCode::TYPE_MISMATCH,
            error_message: "flag type #{parsed_response.value.class} does not match allowed types #{allowed_classes}",
            reason: SDK::Provider::Reason::ERROR
          )
        end

        SDK::Provider::ResolutionDetails.new(
          value: parsed_response.value,
          reason: parsed_response.reason,
          variant: parsed_response.variant,
          flag_metadata: parsed_response.metadata
        )
      rescue UnauthorizedError,
        InvalidOptionError,
        FlagNotFoundError,
        InternalServerError => e
        SDK::Provider::ResolutionDetails.new(
          value: default_value,
          error_code: e.error_code,
          error_message: e.error_message,
          reason: SDK::Provider::Reason::ERROR
        )
      end

      def validate_parameters(flag_key, evaluation_context)
        if evaluation_context.nil? || evaluation_context.targeting_key.nil? || evaluation_context.targeting_key.empty?
          raise InvalidOptionError.new(SDK::Provider::ErrorCode::INVALID_CONTEXT, "invalid evaluation context provided")
        end

        if flag_key.nil? || flag_key.empty?
          raise InvalidOptionError.new(SDK::Provider::ErrorCode::GENERAL, "invalid flag key provided")
        end
      end
    end
  end
end
