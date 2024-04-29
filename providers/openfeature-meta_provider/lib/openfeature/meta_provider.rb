# frozen_string_literal: true

module OpenFeature
  # Used to pull from multiple providers.
  class MetaProvider
    # @param providers [Array<Provider>]
    # @param strategy [Symbol] When `:first_match`, returns first matched resolution. Providers will be searched
    #                          in the order they were given. Defaults to `:first_match`.
    def initialize(providers:, strategy: :first_match)
      @providers = providers
      @strategy = strategy
    end

    def metadata
      SDK::Provider::ProviderMetadata.new(name: "MetaProvider: #{providers.map { |provider| provider.metadata.name }.join(", ")}")
    end

    def init
      providers.each { |provider| provider.init }
    end

    def shutdown
      providers.each(&:shutdown)
    end

    def fetch_boolean_value(flag_key:, default_value:, evaluation_context: nil)
      fetch_from_sources(default_value:) do |provider|
        provider.fetch_boolean_value(flag_key:, default_value:, evaluation_context:)
      end
    end

    def fetch_number_value(flag_key:, default_value:, evaluation_context: nil)
      fetch_from_sources(default_value:) do |provider|
        provider.fetch_number_value(flag_key:, default_value:, evaluation_context:)
      end
    end

    def fetch_object_value(flag_key:, default_value:, evaluation_context: nil)
      fetch_from_sources(default_value:) do |provider|
        provider.fetch_object_value(flag_key:, default_value:, evaluation_context:)
      end
    end

    def fetch_string_value(flag_key:, default_value:, evaluation_context: nil)
      fetch_from_sources(default_value:) do |provider|
        provider.fetch_string_value(flag_key:, default_value:, evaluation_context:)
      end
    end

    private

    attr_reader :providers, :strategy

    def fetch_from_sources(default_value:, &blk)
      case strategy
      when :first_match
        successful_details = providers.each do |provider|
          details = yield(provider)

          break details if details.error_code.nil?
        rescue
          next
        end

        if successful_details.is_a?(SDK::Provider::ResolutionDetails)
          successful_details
        else
          SDK::Provider::ResolutionDetails.new(value: default_value, error_code: SDK::Provider::ErrorCode::GENERAL, reason: SDK::Provider::Reason::ERROR)
        end
      else
        SDK::Provider::ResolutionDetails.new(value: default_value, error_code: SDK::Provider::ErrorCode::GENERAL, reason: "Unknown strategy for MetaProvider")
      end
    end
  end
end
