# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenFeature::MetaProvider::Strategy::FirstSuccessful do
  subject(:strategy) { described_class.new }

  let(:provider_one) do
    OpenFeature::SDK::Provider::InMemoryProvider.new("flag_a" => "from_one")
  end

  let(:provider_two) do
    OpenFeature::SDK::Provider::InMemoryProvider.new("flag_b" => "from_two")
  end

  describe "#resolve" do
    it "returns from the first provider that succeeds" do
      result = strategy.resolve(providers: [provider_one, provider_two], default_value: "default") do |provider|
        provider.fetch_string_value(flag_key: "flag_a", default_value: "default")
      end

      expect(result.value).to eq("from_one")
      expect(result.flag_metadata["matched_provider"]).to eq("In-memory Provider")
    end

    it "skips FLAG_NOT_FOUND and tries the next provider" do
      result = strategy.resolve(providers: [provider_one, provider_two], default_value: "default") do |provider|
        provider.fetch_string_value(flag_key: "flag_b", default_value: "default")
      end

      expect(result.value).to eq("from_two")
    end

    it "stops on non-FLAG_NOT_FOUND errors" do
      error_provider = instance_double(
        OpenFeature::SDK::Provider::InMemoryProvider,
        metadata: OpenFeature::SDK::Provider::ProviderMetadata.new(name: "ErrorProvider")
      )
      allow(error_provider).to receive(:fetch_string_value).and_return(
        OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: "default",
          error_code: OpenFeature::SDK::Provider::ErrorCode::PARSE_ERROR,
          reason: OpenFeature::SDK::Provider::Reason::ERROR
        )
      )

      result = strategy.resolve(providers: [error_provider, provider_two], default_value: "default") do |provider|
        provider.fetch_string_value(flag_key: "flag_b", default_value: "default")
      end

      expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::PARSE_ERROR)
      expect(result.flag_metadata["matched_provider"]).to eq("ErrorProvider")
    end

    it "stops on exceptions and surfaces the error" do
      failing_provider = instance_double(
        OpenFeature::SDK::Provider::InMemoryProvider,
        metadata: OpenFeature::SDK::Provider::ProviderMetadata.new(name: "FailProvider")
      )
      allow(failing_provider).to receive(:fetch_string_value).and_raise(RuntimeError, "connection lost")

      result = strategy.resolve(providers: [failing_provider, provider_two], default_value: "default") do |provider|
        provider.fetch_string_value(flag_key: "flag_b", default_value: "default")
      end

      expect(result.value).to eq("default")
      expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::GENERAL)
      expect(result.error_message).to include("FailProvider")
      expect(result.error_message).to include("connection lost")
    end

    it "returns default error when all providers return FLAG_NOT_FOUND" do
      result = strategy.resolve(providers: [provider_one, provider_two], default_value: "default") do |provider|
        provider.fetch_string_value(flag_key: "missing", default_value: "default")
      end

      expect(result.value).to eq("default")
      expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::GENERAL)
      expect(result.error_message).to eq("No provider found a value for the flag")
    end
  end
end
