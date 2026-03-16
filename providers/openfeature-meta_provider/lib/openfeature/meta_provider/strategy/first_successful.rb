# frozen_string_literal: true

module OpenFeature
  class MetaProvider
    module Strategy
      class FirstSuccessful < Base
        def resolve(providers:, default_value:, &fetch_block)
          providers.each do |provider|
            details = add_provider_metadata(fetch_block.call(provider), provider)

            return details if details.error_code.nil?
            next if details.error_code == SDK::Provider::ErrorCode::FLAG_NOT_FOUND
            return details
          rescue => e
            return default_error_result(
              default_value,
              error_message: "Provider #{provider.metadata.name} raised: #{e.message}"
            )
          end

          default_error_result(default_value, error_message: "No provider found a value for the flag")
        end
      end
    end
  end
end
