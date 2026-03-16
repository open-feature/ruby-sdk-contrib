# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenFeature::MetaProvider::Strategy::Comparison do
  subject(:strategy) { described_class.new }

  let(:provider_one) do
    OpenFeature::SDK::Provider::InMemoryProvider.new("flag_a" => "same_value")
  end

  let(:provider_two) do
    OpenFeature::SDK::Provider::InMemoryProvider.new("flag_a" => "same_value")
  end

  describe "#resolve" do
    it "returns unanimous result when all providers agree" do
      result = strategy.resolve(providers: [provider_one, provider_two], default_value: "default") do |provider|
        provider.fetch_string_value(flag_key: "flag_a", default_value: "default")
      end

      expect(result.value).to eq("same_value")
      expect(result.error_code).to be_nil
      expect(result.flag_metadata["comparison_result"]).to eq("unanimous")
    end

    it "returns mismatch error when providers disagree" do
      disagreeing_provider = OpenFeature::SDK::Provider::InMemoryProvider.new("flag_a" => "different_value")

      result = strategy.resolve(providers: [provider_one, disagreeing_provider], default_value: "default") do |provider|
        provider.fetch_string_value(flag_key: "flag_a", default_value: "default")
      end

      expect(result.value).to eq("default")
      expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::GENERAL)
      expect(result.error_message).to include("Providers disagree")
      expect(result.error_message).to include("same_value")
      expect(result.error_message).to include("different_value")
    end

    it "excludes erroring providers from comparison" do
      error_provider = instance_double(
        OpenFeature::SDK::Provider::InMemoryProvider,
        metadata: OpenFeature::SDK::Provider::ProviderMetadata.new(name: "ErrorProvider")
      )
      allow(error_provider).to receive(:fetch_string_value).and_return(
        OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: "default",
          error_code: OpenFeature::SDK::Provider::ErrorCode::FLAG_NOT_FOUND,
          reason: OpenFeature::SDK::Provider::Reason::ERROR
        )
      )

      result = strategy.resolve(providers: [provider_one, error_provider, provider_two], default_value: "default") do |provider|
        provider.fetch_string_value(flag_key: "flag_a", default_value: "default")
      end

      expect(result.value).to eq("same_value")
      expect(result.flag_metadata["comparison_result"]).to eq("unanimous")
    end

    it "excludes raising providers from comparison" do
      failing_provider = instance_double(
        OpenFeature::SDK::Provider::InMemoryProvider,
        metadata: OpenFeature::SDK::Provider::ProviderMetadata.new(name: "FailProvider")
      )
      allow(failing_provider).to receive(:fetch_string_value).and_raise(RuntimeError, "boom")

      result = strategy.resolve(providers: [provider_one, failing_provider, provider_two], default_value: "default") do |provider|
        provider.fetch_string_value(flag_key: "flag_a", default_value: "default")
      end

      expect(result.value).to eq("same_value")
      expect(result.flag_metadata["comparison_result"]).to eq("unanimous")
    end

    it "returns default error when all providers fail" do
      failing_provider = instance_double(
        OpenFeature::SDK::Provider::InMemoryProvider,
        metadata: OpenFeature::SDK::Provider::ProviderMetadata.new(name: "FailProvider")
      )
      allow(failing_provider).to receive(:fetch_string_value).and_raise(RuntimeError, "boom")

      result = strategy.resolve(providers: [failing_provider], default_value: "default") do |provider|
        provider.fetch_string_value(flag_key: "flag_a", default_value: "default")
      end

      expect(result.value).to eq("default")
      expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::GENERAL)
      expect(result.error_message).to eq("All providers failed")
    end
  end
end
