# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenFeature::MetaProvider::Strategy::FirstMatch do
  subject(:strategy) { described_class.new }

  let(:provider_one) do
    OpenFeature::SDK::Provider::InMemoryProvider.new("flag_a" => "from_one")
  end

  let(:provider_two) do
    OpenFeature::SDK::Provider::InMemoryProvider.new("flag_b" => "from_two")
  end

  describe "#resolve" do
    it "returns from the first provider that matches" do
      result = strategy.resolve(providers: [provider_one, provider_two], default_value: "default") do |provider|
        provider.fetch_string_value(flag_key: "flag_a", default_value: "default")
      end

      expect(result.value).to eq("from_one")
      expect(result.flag_metadata["matched_provider"]).to eq("In-memory Provider")
    end

    it "returns from the second provider when first does not match" do
      result = strategy.resolve(providers: [provider_one, provider_two], default_value: "default") do |provider|
        provider.fetch_string_value(flag_key: "flag_b", default_value: "default")
      end

      expect(result.value).to eq("from_two")
    end

    it "returns default when no providers match" do
      result = strategy.resolve(providers: [provider_one, provider_two], default_value: "default") do |provider|
        provider.fetch_string_value(flag_key: "missing", default_value: "default")
      end

      expect(result.value).to eq("default")
      expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::GENERAL)
      expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::ERROR)
    end

    it "skips providers that raise and tries the next" do
      result = strategy.resolve(providers: [provider_one, provider_two], default_value: "default") do |provider|
        raise "boom" if provider == provider_one
        provider.fetch_string_value(flag_key: "flag_b", default_value: "default")
      end

      expect(result.value).to eq("from_two")
    end
  end
end
