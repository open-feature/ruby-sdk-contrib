# frozen_string_literal: true

module OpenFeature
  class MetaProvider
    module Strategy
      class FirstMatch < Base
        def resolve(providers:, default_value:, &fetch_block)
          successful_details = providers.each do |provider|
            details = add_provider_metadata(fetch_block.call(provider), provider)
            break details if details.error_code.nil?
          rescue
            next
          end

          if successful_details.is_a?(SDK::Provider::ResolutionDetails)
            successful_details
          else
            default_error_result(default_value)
          end
        end
      end
    end
  end
end
