# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenFeature::OFREP::Configuration do
  context "#initialization" do
    it "creates a valid configuration with required params" do
      config = described_class.new(base_url: "http://localhost:8080")
      expect(config.base_url).to eq("http://localhost:8080")
      expect(config.headers).to eq({})
      expect(config.timeout).to eq(10)
    end

    it "creates a valid configuration with all params" do
      config = described_class.new(
        base_url: "https://example.com",
        headers: {"Authorization" => "Bearer token"},
        timeout: 30
      )
      expect(config.base_url).to eq("https://example.com")
      expect(config.headers).to eq({"Authorization" => "Bearer token"})
      expect(config.timeout).to eq(30)
    end

    it "raises if base_url is nil" do
      expect { described_class.new(base_url: nil) }.to raise_error(ArgumentError, "base_url is required")
    end

    it "raises if base_url is empty" do
      expect { described_class.new(base_url: "") }.to raise_error(ArgumentError, "base_url is required")
    end

    it "raises if base_url is invalid" do
      expect { described_class.new(base_url: "invalid_url") }.to raise_error(ArgumentError, "Invalid URL for base_url: invalid_url")
    end

    it "raises if base_url is not http" do
      expect { described_class.new(base_url: "ftp://example.com") }.to raise_error(ArgumentError, "Invalid URL for base_url: ftp://example.com")
    end
  end
end
