# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenFeature::Optimizely::Configuration do
  describe "#initialize" do
    it "accepts sdk_key" do
      config = described_class.new(sdk_key: "test_sdk_key")
      expect(config.sdk_key).to eq("test_sdk_key")
      expect(config.optimizely_client).to be_nil
    end

    it "accepts optimizely_client" do
      mock_client = double("Optimizely::Project")
      config = described_class.new(optimizely_client: mock_client)
      expect(config.optimizely_client).to eq(mock_client)
      expect(config.sdk_key).to be_nil
    end

    it "accepts decide_options" do
      config = described_class.new(sdk_key: "key", decide_options: [:disable_decision_event])
      expect(config.decide_options).to eq([:disable_decision_event])
    end

    it "defaults decide_options to empty array" do
      config = described_class.new(sdk_key: "key")
      expect(config.decide_options).to eq([])
    end

    it "raises error when neither sdk_key nor optimizely_client is provided" do
      expect { described_class.new }.to raise_error(
        ArgumentError, /Either sdk_key or optimizely_client must be provided/
      )
    end

    it "raises error when both sdk_key and optimizely_client are provided" do
      mock_client = double("Optimizely::Project")
      expect {
        described_class.new(sdk_key: "key", optimizely_client: mock_client)
      }.to raise_error(
        ArgumentError, /Only one of sdk_key or optimizely_client can be provided/
      )
    end

    it "raises error when sdk_key is empty" do
      expect {
        described_class.new(sdk_key: "")
      }.to raise_error(ArgumentError, /sdk_key cannot be empty/)
    end

    it "raises error when sdk_key is whitespace only" do
      expect {
        described_class.new(sdk_key: "   ")
      }.to raise_error(ArgumentError, /sdk_key cannot be empty/)
    end
  end
end
