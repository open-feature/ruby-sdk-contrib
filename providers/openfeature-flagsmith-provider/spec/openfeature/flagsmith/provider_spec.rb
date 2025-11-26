require "spec_helper"
require "openfeature/flagsmith/provider"

RSpec.describe OpenFeature::Flagsmith::Provider do
  let(:options) do
    OpenFeature::Flagsmith::Options.new(environment_key: "test_key_123")
  end

  let(:provider) { described_class.new(options: options) }

  let(:mock_flagsmith_client) { instance_double("Flagsmith::Client") }
  let(:mock_flags) { double("Flags") }

  # Helper to create a mock flag object for all_flags
  def mock_flag(feature_name:, enabled:, value:)
    double("Flag", feature_name: feature_name, enabled: enabled, value: value)
  end

  before do
    # Mock Flagsmith::Client creation
    allow(::Flagsmith::Client).to receive(:new).and_return(mock_flagsmith_client)
  end

  describe "#initialize" do
    it "should create provider with options" do
      expect(provider.options).to eq(options)
    end

    it "should set metadata with provider name" do
      expect(provider.metadata).to be_a(OpenFeature::SDK::Provider::ProviderMetadata)
      expect(provider.metadata.name).to eq("Flagsmith Provider")
    end
  end

  describe "#metadata" do
    it "should return provider metadata" do
      expect(provider.metadata.name).to eq("Flagsmith Provider")
    end
  end

  describe "#init" do
    it "should initialize Flagsmith client" do
      expect(::Flagsmith::Client).to receive(:new).with(
        environment_key: "test_key_123",
        api_url: "https://edge.api.flagsmith.com/api/v1/",
        enable_local_evaluation: false,
        request_timeout_seconds: 10,
        enable_analytics: false,
        environment_refresh_interval_seconds: 60
      ).and_return(mock_flagsmith_client)

      expect { provider.init }.not_to raise_error
    end
  end

  describe "#shutdown" do
    it "should shutdown without error" do
      expect { provider.shutdown }.not_to raise_error
    end
  end

  describe "fetch methods" do
    let(:flag_key) { "test_flag" }
    let(:evaluation_context) do
      OpenFeature::SDK::EvaluationContext.new(targeting_key: "user_123")
    end

    before do
      provider.init
    end

    describe "#fetch_boolean_value" do
      it "should return ResolutionDetails" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:get_feature_value).with(flag_key).and_return(nil)
        allow(mock_flags).to receive(:is_feature_enabled).with(flag_key).and_return(false)

        result = provider.fetch_boolean_value(
          flag_key: flag_key,
          default_value: false,
          evaluation_context: evaluation_context
        )
        expect(result).to be_a(OpenFeature::SDK::Provider::ResolutionDetails)
      end

      it "should return actual flag value when flag exists" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:get_feature_value).with(flag_key).and_return("something")
        allow(mock_flags).to receive(:is_feature_enabled).with(flag_key).and_return(true)

        result = provider.fetch_boolean_value(
          flag_key: flag_key,
          default_value: false,
          evaluation_context: evaluation_context
        )
        expect(result.value).to eq(true)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
        expect(result.error_code).to be_nil
      end

      it "should return false for disabled boolean flags" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:get_feature_value).with(flag_key).and_return(nil)
        allow(mock_flags).to receive(:is_feature_enabled).with(flag_key).and_return(false)

        result = provider.fetch_boolean_value(
          flag_key: flag_key,
          default_value: true,
          evaluation_context: evaluation_context
        )
        expect(result.value).to eq(false)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
        expect(result.error_code).to be_nil
      end

      it "should work without evaluation context" do
        allow(mock_flagsmith_client).to receive(:get_environment_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:get_feature_value).with(flag_key).and_return(nil)
        allow(mock_flags).to receive(:is_feature_enabled).with(flag_key).and_return(false)

        result = provider.fetch_boolean_value(
          flag_key: flag_key,
          default_value: true
        )
        expect(result).to be_a(OpenFeature::SDK::Provider::ResolutionDetails)
        expect(result.value).to eq(false)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::STATIC)
      end

      it "should handle non-string targeting_key gracefully" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:get_feature_value).and_return(nil)
        allow(mock_flags).to receive(:is_feature_enabled).and_return(false)
        evaluation_context = OpenFeature::SDK::EvaluationContext.new(targeting_key: 12345)

        result = provider.fetch_boolean_value(
          flag_key: flag_key,
          default_value: false,
          evaluation_context: evaluation_context
        )
        expect(result).to be_a(OpenFeature::SDK::Provider::ResolutionDetails)
      end
    end

    describe "#fetch_string_value" do
      it "should return ResolutionDetails" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([])

        result = provider.fetch_string_value(
          flag_key: flag_key,
          default_value: "default",
          evaluation_context: evaluation_context
        )
        expect(result).to be_a(OpenFeature::SDK::Provider::ResolutionDetails)
      end

      it "should return actual string value when flag exists" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: flag_key, enabled: true, value: "hello_world")
        ])

        result = provider.fetch_string_value(
          flag_key: flag_key,
          default_value: "default",
          evaluation_context: evaluation_context
        )
        expect(result.value).to eq("hello_world")
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
      end

      it "should return default value when flag not found" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([])

        result = provider.fetch_string_value(
          flag_key: flag_key,
          default_value: "default_string",
          evaluation_context: evaluation_context
        )
        expect(result.value).to eq("default_string")
      end
    end

    describe "#fetch_number_value" do
      it "should return ResolutionDetails" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([])

        result = provider.fetch_number_value(
          flag_key: flag_key,
          default_value: 42,
          evaluation_context: evaluation_context
        )
        expect(result).to be_a(OpenFeature::SDK::Provider::ResolutionDetails)
      end

      it "should parse numeric string value" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: flag_key, enabled: true, value: "123")
        ])

        result = provider.fetch_number_value(
          flag_key: flag_key,
          default_value: 0,
          evaluation_context: evaluation_context
        )
        expect(result.value).to eq(123)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
      end

      it "should return actual numeric value" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: flag_key, enabled: true, value: 456)
        ])

        result = provider.fetch_number_value(
          flag_key: flag_key,
          default_value: 0,
          evaluation_context: evaluation_context
        )
        expect(result.value).to eq(456)
      end

      it "should return default value when flag not found" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([])

        result = provider.fetch_number_value(
          flag_key: flag_key,
          default_value: 123,
          evaluation_context: evaluation_context
        )
        expect(result.value).to eq(123)
      end
    end

    describe "#fetch_integer_value" do
      it "should return ResolutionDetails" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([])

        result = provider.fetch_integer_value(
          flag_key: flag_key,
          default_value: 42,
          evaluation_context: evaluation_context
        )
        expect(result).to be_a(OpenFeature::SDK::Provider::ResolutionDetails)
      end
    end

    describe "#fetch_float_value" do
      it "should return ResolutionDetails" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([])

        result = provider.fetch_float_value(
          flag_key: flag_key,
          default_value: 3.14,
          evaluation_context: evaluation_context
        )
        expect(result).to be_a(OpenFeature::SDK::Provider::ResolutionDetails)
      end
    end

    describe "#fetch_object_value" do
      it "should return ResolutionDetails" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([])

        result = provider.fetch_object_value(
          flag_key: flag_key,
          default_value: {key: "value"},
          evaluation_context: evaluation_context
        )
        expect(result).to be_a(OpenFeature::SDK::Provider::ResolutionDetails)
      end

      it "should parse JSON string to hash" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: flag_key, enabled: true, value: '{"color":"red","size":42}')
        ])

        result = provider.fetch_object_value(
          flag_key: flag_key,
          default_value: {},
          evaluation_context: evaluation_context
        )
        expect(result.value).to eq({"color" => "red", "size" => 42})
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
      end

      it "should return hash value directly" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: flag_key, enabled: true, value: {foo: "bar"})
        ])

        result = provider.fetch_object_value(
          flag_key: flag_key,
          default_value: {},
          evaluation_context: evaluation_context
        )
        expect(result.value).to eq({foo: "bar"})
      end

      it "should return default value when flag not found" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([])

        result = provider.fetch_object_value(
          flag_key: flag_key,
          default_value: {default: true},
          evaluation_context: evaluation_context
        )
        expect(result.value).to eq({default: true})
      end
    end
  end

  describe "reason determination" do
    before do
      provider.init
      allow(mock_flags).to receive(:get_feature_value).and_return(nil)
      allow(mock_flags).to receive(:is_feature_enabled).and_return(false)
    end

    it "should use STATIC reason for environment-level flags (no targeting_key)" do
      allow(mock_flagsmith_client).to receive(:get_environment_flags).and_return(mock_flags)

      evaluation_context = OpenFeature::SDK::EvaluationContext.new
      result = provider.fetch_boolean_value(
        flag_key: "test",
        default_value: true,
        evaluation_context: evaluation_context
      )
      # Boolean flags always return their value with STATIC/TARGETING_MATCH reason
      expect(result.value).to eq(false)
      expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::STATIC)
    end

    it "should use TARGETING_MATCH reason for identity-specific flags" do
      allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)

      evaluation_context = OpenFeature::SDK::EvaluationContext.new(targeting_key: "user_123")
      result = provider.fetch_boolean_value(
        flag_key: "test",
        default_value: true,
        evaluation_context: evaluation_context
      )
      # Flagsmith treats non-existent flags as disabled flags
      expect(result.value).to eq(false)
      expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
    end
  end

  describe "error handling scenarios" do
    let(:flag_key) { "test_flag" }
    let(:evaluation_context) do
      OpenFeature::SDK::EvaluationContext.new(targeting_key: "user_123")
    end

    before do
      provider.init
    end

    describe "when provider is not initialized" do
      it "should return error when client is nil" do
        provider_uninit = described_class.new(options: options)
        # Don't call init

        result = provider_uninit.fetch_boolean_value(
          flag_key: flag_key,
          default_value: false,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(false)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::ERROR)
        expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::PROVIDER_NOT_READY)
        expect(result.error_message).to include("Provider not initialized")
      end
    end

    describe "when Flagsmith client raises errors" do
      it "should handle network errors from get_identity_flags" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags)
          .and_raise(StandardError.new("Network timeout"))

        result = provider.fetch_boolean_value(
          flag_key: flag_key,
          default_value: false,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(false)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::ERROR)
        expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::GENERAL)
        expect(result.error_message).to include("Network timeout")
      end

      it "should handle network errors from get_environment_flags" do
        allow(mock_flagsmith_client).to receive(:get_environment_flags)
          .and_raise(StandardError.new("Connection refused"))

        result = provider.fetch_boolean_value(
          flag_key: flag_key,
          default_value: false,
          evaluation_context: nil
        )

        expect(result.value).to eq(false)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::ERROR)
        expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::GENERAL)
      end

      it "should handle errors when getting flags object itself" do
        # Test error when get_identity_flags itself fails (not the flag methods)
        allow(mock_flagsmith_client).to receive(:get_identity_flags)
          .and_raise(StandardError.new("API error"))

        result = provider.fetch_string_value(
          flag_key: flag_key,
          default_value: "default",
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq("default")
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::ERROR)
        expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::GENERAL)
      end
    end

    describe "JSON parsing errors" do
      it "should handle malformed JSON in object values" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: flag_key, enabled: true, value: "{invalid json")
        ])

        result = provider.fetch_object_value(
          flag_key: flag_key,
          default_value: {default: true},
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq({default: true})
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::ERROR)
        expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::PARSE_ERROR)
      end
    end

    describe "type mismatch errors" do
      it "should return error when boolean flag returns non-boolean value" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: flag_key, enabled: true, value: "not_a_boolean")
        ])

        result = provider.fetch_string_value(
          flag_key: flag_key,
          default_value: "default",
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq("not_a_boolean")
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
      end

      it "should return error when string value cannot be converted to integer" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: flag_key, enabled: true, value: "not_a_number")
        ])

        result = provider.fetch_integer_value(
          flag_key: flag_key,
          default_value: 42,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(42)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::ERROR)
        expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::PARSE_ERROR)
      end
    end

    describe "Flagsmith client initialization errors" do
      it "should raise ProviderNotReadyError when Flagsmith::Client.new fails" do
        allow(::Flagsmith::Client).to receive(:new).and_raise(StandardError.new("Invalid API key"))

        provider_new = described_class.new(options: options)

        expect {
          provider_new.init
        }.to raise_error(OpenFeature::Flagsmith::ProviderNotReadyError, /Failed to create Flagsmith client/)
      end
    end
  end

  describe "edge cases" do
    let(:evaluation_context) do
      OpenFeature::SDK::EvaluationContext.new(targeting_key: "user_123")
    end

    before do
      provider.init
    end

    describe "empty or nil flag keys" do
      it "should handle empty string flag key" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:get_feature_value).with("").and_return(nil)
        allow(mock_flags).to receive(:is_feature_enabled).with("").and_return(false)

        result = provider.fetch_boolean_value(
          flag_key: "",
          default_value: true,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(true)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::DEFAULT)
      end
    end

    describe "special characters in flag keys" do
      it "should handle flag keys with special characters" do
        special_key = "flag-with-dashes_and_underscores.and.dots"
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: special_key, enabled: true, value: "value")
        ])

        result = provider.fetch_string_value(
          flag_key: special_key,
          default_value: "default",
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq("value")
      end

    end

    describe "evaluation context edge cases" do
      it "should handle empty string targeting_key" do
        allow(mock_flagsmith_client).to receive(:get_environment_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:is_feature_enabled).and_return(false)

        context = OpenFeature::SDK::EvaluationContext.new(targeting_key: "")
        result = provider.fetch_boolean_value(
          flag_key: "test",
          default_value: false,
          evaluation_context: context
        )

        expect(result).to be_a(OpenFeature::SDK::Provider::ResolutionDetails)
      end

      it "should handle whitespace-only targeting_key" do
        allow(mock_flagsmith_client).to receive(:get_environment_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:is_feature_enabled).and_return(false)

        context = OpenFeature::SDK::EvaluationContext.new(targeting_key: "   ")
        result = provider.fetch_boolean_value(
          flag_key: "test",
          default_value: false,
          evaluation_context: context
        )

        expect(result).to be_a(OpenFeature::SDK::Provider::ResolutionDetails)
      end

      it "should handle nil values in context fields (traits)" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:is_feature_enabled).and_return(false)

        context = OpenFeature::SDK::EvaluationContext.new(
          targeting_key: "user_123",
          email: nil,
          age: nil
        )

        result = provider.fetch_boolean_value(
          flag_key: "test",
          default_value: false,
          evaluation_context: context
        )

        expect(result).to be_a(OpenFeature::SDK::Provider::ResolutionDetails)
      end

      it "should handle unicode in trait values" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: "test", enabled: true, value: "value")
        ])

        context = OpenFeature::SDK::EvaluationContext.new(
          targeting_key: "user_123",
          name: "François",
          location: "Montréal 🇨🇦"
        )

        result = provider.fetch_string_value(
          flag_key: "test",
          default_value: "default",
          evaluation_context: context
        )

        expect(result.value).to eq("value")
      end
    end

    describe "numeric type edge cases" do
      it "should handle zero values" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: "test", enabled: true, value: 0)
        ])

        result = provider.fetch_integer_value(
          flag_key: "test",
          default_value: 42,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(0)
      end

      it "should handle negative numbers" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: "test", enabled: true, value: -999)
        ])

        result = provider.fetch_integer_value(
          flag_key: "test",
          default_value: 0,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(-999)
      end

      it "should handle very large numbers" do
        large_num = 999_999_999_999
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: "test", enabled: true, value: large_num)
        ])

        result = provider.fetch_integer_value(
          flag_key: "test",
          default_value: 0,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(large_num)
      end

      it "should handle scientific notation in strings" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: "test", enabled: true, value: "1.5e2")
        ])

        result = provider.fetch_float_value(
          flag_key: "test",
          default_value: 0.0,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(150.0)
      end
    end

    describe "object/array edge cases" do
      it "should handle empty objects" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: "test", enabled: true, value: {})
        ])

        result = provider.fetch_object_value(
          flag_key: "test",
          default_value: {default: true},
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq({})
      end

      it "should handle empty arrays" do
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: "test", enabled: true, value: [])
        ])

        result = provider.fetch_object_value(
          flag_key: "test",
          default_value: [],
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq([])
      end

      it "should handle nested objects" do
        nested = {outer: {inner: {deep: "value"}}}
        allow(mock_flagsmith_client).to receive(:get_identity_flags).and_return(mock_flags)
        allow(mock_flags).to receive(:all_flags).and_return([
          mock_flag(feature_name: "test", enabled: true, value: nested)
        ])

        result = provider.fetch_object_value(
          flag_key: "test",
          default_value: {},
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(nested)
      end
    end
  end
end
