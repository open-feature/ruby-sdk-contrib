require "spec_helper"
require "openfeature/flagsmith/error/errors"

RSpec.describe "Flagsmith Errors" do
  describe OpenFeature::Flagsmith::FlagNotFoundError do
    it "should create error with FLAG_NOT_FOUND error code" do
      error = OpenFeature::Flagsmith::FlagNotFoundError.new("my_flag")
      expect(error.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::FLAG_NOT_FOUND)
      expect(error.error_message).to eq("Flag not found: my_flag")
      expect(error.message).to eq("Flag not found: my_flag")
    end

    it "should be a StandardError" do
      error = OpenFeature::Flagsmith::FlagNotFoundError.new("test")
      expect(error).to be_a(StandardError)
    end
  end

  describe OpenFeature::Flagsmith::TypeMismatchError do
    it "should create error with TYPE_MISMATCH error code" do
      error = OpenFeature::Flagsmith::TypeMismatchError.new([String], Integer)
      expect(error.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::TYPE_MISMATCH)
      expect(error.error_message).to include("Expected type")
      expect(error.error_message).to include("Integer")
    end
  end

  describe OpenFeature::Flagsmith::ProviderNotReadyError do
    it "should create error with PROVIDER_NOT_READY error code" do
      error = OpenFeature::Flagsmith::ProviderNotReadyError.new
      expect(error.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::PROVIDER_NOT_READY)
      expect(error.error_message).to eq("Flagsmith provider is not ready")
    end

    it "should accept custom message" do
      error = OpenFeature::Flagsmith::ProviderNotReadyError.new("Client not initialized")
      expect(error.error_message).to eq("Client not initialized")
    end
  end

  describe OpenFeature::Flagsmith::ParseError do
    it "should create error with PARSE_ERROR error code" do
      error = OpenFeature::Flagsmith::ParseError.new("invalid JSON")
      expect(error.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::PARSE_ERROR)
      expect(error.error_message).to eq("Failed to parse flag value: invalid JSON")
    end
  end

  describe OpenFeature::Flagsmith::FlagsmithClientError do
    it "should create error with GENERAL error code" do
      error = OpenFeature::Flagsmith::FlagsmithClientError.new("connection timeout")
      expect(error.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::GENERAL)
      expect(error.error_message).to eq("Flagsmith client error: connection timeout")
    end
  end

  describe OpenFeature::Flagsmith::InvalidContextError do
    it "should create error with INVALID_CONTEXT error code" do
      error = OpenFeature::Flagsmith::InvalidContextError.new("missing required field")
      expect(error.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::INVALID_CONTEXT)
      expect(error.error_message).to eq("Invalid evaluation context: missing required field")
    end
  end

  describe OpenFeature::Flagsmith::FlagsmithError do
    it "should be the base class for all Flagsmith errors" do
      expect(OpenFeature::Flagsmith::FlagNotFoundError.new("test")).to be_a(OpenFeature::Flagsmith::FlagsmithError)
      expect(OpenFeature::Flagsmith::TypeMismatchError.new([], nil)).to be_a(OpenFeature::Flagsmith::FlagsmithError)
      expect(OpenFeature::Flagsmith::ProviderNotReadyError.new).to be_a(OpenFeature::Flagsmith::FlagsmithError)
    end
  end
end
