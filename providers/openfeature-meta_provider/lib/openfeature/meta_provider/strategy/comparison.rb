# frozen_string_literal: true

module OpenFeature
  class MetaProvider
    module Strategy
      class Comparison < Base
        def resolve(providers:, default_value:, &fetch_block)
          results = []
          errors = []

          providers.each do |provider|
            details = fetch_block.call(provider)

            if details.error_code.nil?
              results << add_provider_metadata(details, provider)
            else
              errors << {provider: provider.metadata.name, error_code: details.error_code}
            end
          rescue => e
            errors << {provider: provider.metadata.name, error_code: e.message}
          end

          return default_error_result(default_value, error_message: "All providers failed") if results.empty?

          if results.all? { |r| r.value == results.first.value }
            with_merged_metadata(results.first, "comparison_result" => "unanimous")
          else
            mismatch_details = results.map { |r| "#{r.flag_metadata[MATCHED_PROVIDER_KEY]}=#{r.value.inspect}" }.join(", ")
            default_error_result(
              default_value,
              error_message: "Providers disagree: #{mismatch_details}"
            )
          end
        end
      end
    end
  end
end
