# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenFeature::MetaProvider::Strategy::Base do
  describe "#resolve" do
    it "raises NotImplementedError" do
      base = described_class.new
      expect {
        base.resolve(providers: [], default_value: false) { |_| }
      }.to raise_error(NotImplementedError, /must be implemented/)
    end
  end

  describe "custom subclass" do
    let(:custom_strategy_class) do
      Class.new(described_class) do
        def resolve(providers:, default_value:, &fetch_block)
          details = fetch_block.call(providers.last)
          add_provider_metadata(details, providers.last)
        end
      end
    end

    it "works when subclassed with resolve implemented" do
      provider = OpenFeature::SDK::Provider::InMemoryProvider.new("my_flag" => true)
      strategy = custom_strategy_class.new

      result = strategy.resolve(providers: [provider], default_value: false) do |p|
        p.fetch_boolean_value(flag_key: "my_flag", default_value: false)
      end

      expect(result.value).to eq(true)
      expect(result.flag_metadata["matched_provider"]).to eq("In-memory Provider")
    end
  end
end
