# frozen_string_literal: true

module OpenFeature
  class MetaProvider
    module Strategy
      class Base
        MATCHED_PROVIDER_KEY = "matched_provider"

        def resolve(providers:, default_value:, &fetch_block)
          raise NotImplementedError, "#{self.class}#resolve must be implemented"
        end

        private

        def add_provider_metadata(details, provider)
          with_merged_metadata(details, MATCHED_PROVIDER_KEY => provider.metadata.name)
        end

        def with_merged_metadata(details, extra_metadata)
          SDK::Provider::ResolutionDetails.new(
            value: details.value,
            reason: details.reason,
            variant: details.variant,
            error_code: details.error_code,
            error_message: details.error_message,
            flag_metadata: (details.flag_metadata || {}).merge(extra_metadata)
          )
        end

        def default_error_result(default_value, error_message: nil)
          SDK::Provider::ResolutionDetails.new(
            value: default_value,
            error_code: SDK::Provider::ErrorCode::GENERAL,
            reason: SDK::Provider::Reason::ERROR,
            error_message: error_message
          )
        end
      end
    end
  end
end
