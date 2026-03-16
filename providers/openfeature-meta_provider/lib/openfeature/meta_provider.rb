# frozen_string_literal: true

require_relative "meta_provider/strategy/base"
require_relative "meta_provider/strategy/first_match"
require_relative "meta_provider/strategy/first_successful"
require_relative "meta_provider/strategy/comparison"

module OpenFeature
  # Used to pull from multiple providers.
  class MetaProvider
    STRATEGY_MAP = {
      first_match: Strategy::FirstMatch.new,
      first_successful: Strategy::FirstSuccessful.new,
      comparison: Strategy::Comparison.new
    }.freeze

    FETCH_TYPES = %w[boolean string number integer float object].freeze

    # @param providers [Array<Provider>]
    # @param strategy [Symbol, Strategy::Base] Resolution strategy. Accepts a symbol (:first_match,
    #   :first_successful, :comparison) or a Strategy::Base subclass instance for custom strategies.
    #   Defaults to :first_match.
    def initialize(providers:, strategy: :first_match)
      @providers = providers
      @strategy = resolve_strategy(strategy)
    end

    def metadata
      @metadata ||= SDK::Provider::ProviderMetadata.new(name: "MetaProvider: #{providers.map do |provider|
        provider.metadata.name
      end.join(", ")}")
    end

    def init(evaluation_context = nil)
      providers.each { |provider| provider.init(evaluation_context) if provider.respond_to?(:init) }
    end

    def shutdown
      providers.each { |provider| provider.shutdown if provider.respond_to?(:shutdown) }
    end

    FETCH_TYPES.each do |type|
      define_method(:"fetch_#{type}_value") do |flag_key:, default_value:, evaluation_context: nil|
        strategy.resolve(providers: providers, default_value: default_value) do |provider|
          provider.send(:"fetch_#{type}_value", flag_key: flag_key, default_value: default_value,
            evaluation_context: evaluation_context)
        end
      end
    end

    def track(tracking_event_name, evaluation_context: nil, tracking_event_details: nil)
      providers.each do |provider|
        if provider.respond_to?(:track)
          provider.track(tracking_event_name, evaluation_context: evaluation_context,
            tracking_event_details: tracking_event_details)
        end
      end
    end

    private

    attr_reader :providers, :strategy

    def resolve_strategy(strategy)
      return strategy if strategy.is_a?(Strategy::Base)

      STRATEGY_MAP.fetch(strategy) do
        raise ArgumentError, "Unknown strategy: #{strategy.inspect}. " \
          "Valid symbols: #{STRATEGY_MAP.keys.map(&:inspect).join(", ")}. " \
          "Or pass a Strategy::Base subclass instance."
      end
    end
  end
end
