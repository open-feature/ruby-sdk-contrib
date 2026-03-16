# frozen_string_literal: true

require "spec_helper"
require_relative "../../../../shared_config/conformance/provider_shared_examples"

RSpec.shared_examples "meta resolution" do |type, default_value, first_matched_value, second_matched_value|
  context "when strategy is first_match" do
    context "and first provider matches" do
      let(:flag_key) { "first_match_#{type}" }

      it "returns from first" do
        expected_result = OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: first_matched_value,
          reason: OpenFeature::SDK::Provider::Reason::STATIC,
          flag_metadata: {"matched_provider" => "In-memory Provider"}
        )

        result = meta_provider.send(:"fetch_#{type}_value", flag_key:, default_value:)

        expect(result).to eq(expected_result)
      end
    end

    context "and second provider matches" do
      let(:flag_key) { "second_match_#{type}" }

      it "returns from second" do
        expected_result = OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: second_matched_value,
          reason: OpenFeature::SDK::Provider::Reason::STATIC,
          flag_metadata: {"matched_provider" => "In-memory Provider"}
        )

        result = meta_provider.send(:"fetch_#{type}_value", flag_key:, default_value:)

        expect(result).to eq(expected_result)
      end
    end

    context "and no providers match" do
      let(:flag_key) { "not anywhere" }

      it "returns default" do
        result = meta_provider.send(:"fetch_#{type}_value", flag_key:, default_value:)

        expect(result).to eq(OpenFeature::SDK::Provider::ResolutionDetails.new(value: default_value,
          reason: OpenFeature::SDK::Provider::Reason::ERROR, error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL))
      end
    end

    context "and provider raises" do
      let(:flag_key) { "first_match_#{type}" }

      before { allow(provider_one).to receive(:"fetch_#{type}_value").and_raise }

      it "returns default" do
        result = meta_provider.send(:"fetch_#{type}_value", flag_key:, default_value:)

        expect(result).to eq(OpenFeature::SDK::Provider::ResolutionDetails.new(value: default_value,
          reason: OpenFeature::SDK::Provider::Reason::ERROR, error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL))
      end
    end
  end
end

RSpec.describe OpenFeature::MetaProvider do
  subject(:meta_provider) { described_class.new(providers: [provider_one, provider_two]) }
  let(:provider) { meta_provider }

  let(:provider_one) do
    OpenFeature::SDK::Provider::InMemoryProvider.new(
      {
        "first_match_boolean" => true,
        "first_match_string" => "first",
        "first_match_number" => 1,
        "first_match_integer" => 10,
        "first_match_float" => 1.5,
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
        "second_match_integer" => 20,
        "second_match_float" => 2.5,
        "second_match_object" => {two: 2}
      }
    )
  end

  describe "conformance" do
    let(:provider) { meta_provider }

    it_behaves_like "an OpenFeature provider"
    it_behaves_like "an OpenFeature provider with integer and float support"
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

    it "accepts an optional evaluation_context" do
      expect { meta_provider.init(nil) }.not_to raise_error
    end
  end

  describe "#shutdown" do
    it "calls all providers' shutdowns" do
      expect(provider_one).to receive(:shutdown)
      expect(provider_two).to receive(:shutdown)

      meta_provider.shutdown
    end

    it "guards against providers without shutdown" do
      no_shutdown_provider = Object.new
      def no_shutdown_provider.metadata
        OpenFeature::SDK::Provider::ProviderMetadata.new(name: "NoShutdown")
      end

      mp = described_class.new(providers: [no_shutdown_provider])
      expect { mp.shutdown }.not_to raise_error
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

  describe "#fetch_integer_value" do
    include_examples "meta resolution", "integer", 0, 10, 20
  end

  describe "#fetch_float_value" do
    include_examples "meta resolution", "float", 0.0, 1.5, 2.5
  end

  describe "#fetch_object_value" do
    include_examples "meta resolution", "object", {}, {one: 1}, {two: 2}
  end

  describe "#track" do
    it "delegates to all providers that respond to track" do
      trackable_class = Class.new do
        attr_reader :metadata, :tracked_calls

        def initialize
          @metadata = OpenFeature::SDK::Provider::ProviderMetadata.new(name: "Trackable")
          @tracked_calls = []
        end

        def track(event_name, evaluation_context: nil, tracking_event_details: nil)
          @tracked_calls << {event_name: event_name, evaluation_context: evaluation_context,
                             tracking_event_details: tracking_event_details}
        end

        def init = nil

        def shutdown = nil
      end

      trackable = trackable_class.new

      mp = described_class.new(providers: [trackable, provider_one])
      mp.track("event_name", evaluation_context: nil, tracking_event_details: nil)

      expect(trackable.tracked_calls).to eq([{
        event_name: "event_name",
        evaluation_context: nil,
        tracking_event_details: nil
      }])
    end
  end

  describe "strategy acceptance" do
    it "accepts :first_match symbol" do
      expect { described_class.new(providers: [provider_one], strategy: :first_match) }.not_to raise_error
    end

    it "accepts :first_successful symbol" do
      expect { described_class.new(providers: [provider_one], strategy: :first_successful) }.not_to raise_error
    end

    it "accepts :comparison symbol" do
      expect { described_class.new(providers: [provider_one], strategy: :comparison) }.not_to raise_error
    end

    it "accepts a Strategy::Base subclass instance" do
      custom = OpenFeature::MetaProvider::Strategy::FirstMatch.new
      expect { described_class.new(providers: [provider_one], strategy: custom) }.not_to raise_error
    end

    it "raises ArgumentError for invalid strategy symbol" do
      expect { described_class.new(providers: [provider_one], strategy: :invalid) }
        .to raise_error(ArgumentError, /Unknown strategy/)
    end
  end
end
