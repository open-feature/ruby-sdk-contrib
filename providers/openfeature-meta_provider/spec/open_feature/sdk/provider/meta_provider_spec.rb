# frozen_string_literal: true

require "spec_helper"

RSpec.shared_examples "meta resolution" do |type, default_value, first_matched_value, second_matched_value|
  context "when strategy is first_match" do
    context "and first provider matches" do
      let(:flag_key) { "first_match_#{type}" }

      it "returns from first" do
        result = meta_provider.send(:"fetch_#{type}_value", flag_key:, default_value:)

        expect(result).to eq(OpenFeature::SDK::Provider::ResolutionDetails.new(value: first_matched_value, reason: OpenFeature::SDK::Provider::Reason::STATIC))
      end
    end

    context "and second provider matches" do
      let(:flag_key) { "second_match_#{type}" }

      it "returns from second" do
        result = meta_provider.send(:"fetch_#{type}_value", flag_key:, default_value:)

        expect(result).to eq(OpenFeature::SDK::Provider::ResolutionDetails.new(value: second_matched_value, reason: OpenFeature::SDK::Provider::Reason::STATIC))
      end
    end

    context "and no providers match" do
      let(:flag_key) { "not anywhere" }

      it "returns default" do
        result = meta_provider.send(:"fetch_#{type}_value", flag_key:, default_value:)

        expect(result).to eq(OpenFeature::SDK::Provider::ResolutionDetails.new(value: default_value, reason: OpenFeature::SDK::Provider::Reason::ERROR, error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL))
      end
    end

    context "and provider raises" do
      let(:flag_key) { "first_match_#{type}" }

      before { allow(provider_one).to receive(:"fetch_#{type}_value").and_raise }

      it "returns default" do
        result = meta_provider.send(:"fetch_#{type}_value", flag_key:, default_value:)

        expect(result).to eq(OpenFeature::SDK::Provider::ResolutionDetails.new(value: default_value, reason: OpenFeature::SDK::Provider::Reason::ERROR, error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL))
      end
    end
  end
end

RSpec.describe OpenFeature::SDK::Provider::MetaProvider do
  subject(:meta_provider) { described_class.new(providers: [provider_one, provider_two]) }

  let(:provider_one) do
    OpenFeature::SDK::Provider::InMemoryProvider.new(
      {
        "first_match_boolean" => true,
        "first_match_string" => "first",
        "first_match_number" => 1,
        "first_match_object" => {one: 1}
      }
    )
  end
  let(:provider_two) do
    OpenFeature::SDK::Provider::InMemoryProvider.new(
      {
        "second_match_boolean" => false,
        "second_match_string" => "second",
        "second_match_number" => 2,
        "second_match_object" => {two: 2}
      }
    )
  end

  describe "#metadata" do
    it "combines all metadata names" do
      expect(meta_provider.metadata.name).to eq("MetaProvider: In-memory Provider, In-memory Provider")
    end
  end

  describe "#init" do
    it "calls all providers' inits" do
      expect(provider_one).to receive(:init)
      expect(provider_two).to receive(:init)

      meta_provider.init
    end
  end

  describe "#shutdown" do
    it "calls all providers' shutdowns" do
      expect(provider_one).to receive(:shutdown)
      expect(provider_two).to receive(:shutdown)

      meta_provider.shutdown
    end
  end

  describe "#fetch_boolean_value" do
    include_examples "meta resolution", "boolean", false, true, false
  end

  describe "#fetch_string_value" do
    include_examples "meta resolution", "string", "fallback", "first", "second"
  end

  describe "#fetch_number_value" do
    include_examples "meta resolution", "number", 3, 1, 2
  end

  describe "#fetch_object_value" do
    include_examples "meta resolution", "object", {}, {one: 1}, {two: 2}
  end
end
