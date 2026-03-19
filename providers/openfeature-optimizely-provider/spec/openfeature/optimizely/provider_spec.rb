# frozen_string_literal: true

require "spec_helper"
require "openfeature/optimizely/provider"
require_relative "../../../../../shared_config/conformance/provider_shared_examples"

RSpec.describe OpenFeature::Optimizely::Provider do
  let(:configuration) do
    OpenFeature::Optimizely::Configuration.new(sdk_key: "test_sdk_key")
  end

  let(:provider) { described_class.new(configuration: configuration) }

  let(:mock_optimizely_client) { instance_double("Optimizely::Project") }
  let(:mock_user_context) { double("OptimizelyUserContext") }

  def mock_decision(flag_key:, enabled:, variables: {}, variation_key: "variation_1", rule_key: nil)
    double("OptimizelyDecision",
      flag_key: flag_key,
      enabled: enabled,
      variables: variables,
      variation_key: variation_key,
      rule_key: rule_key)
  end

  before do
    allow(::Optimizely::Project).to receive(:new)
      .and_return(mock_optimizely_client)
  end

  it_behaves_like "an OpenFeature provider"
  it_behaves_like "an OpenFeature provider with integer and float support"

  describe "#initialize" do
    it "creates provider with configuration" do
      expect(provider.configuration).to eq(configuration)
    end

    it "sets metadata with provider name" do
      expect(provider.metadata).to be_a(OpenFeature::SDK::Provider::ProviderMetadata)
      expect(provider.metadata.name).to eq("Optimizely Provider")
    end
  end

  describe "#init" do
    it "creates Optimizely client from sdk_key" do
      expect(::Optimizely::Project).to receive(:new)
        .with(sdk_key: "test_sdk_key")
        .and_return(mock_optimizely_client)

      provider.init
    end

    it "uses provided optimizely_client" do
      custom_client = double("Optimizely::Project")
      config = OpenFeature::Optimizely::Configuration.new(optimizely_client: custom_client)
      prov = described_class.new(configuration: config)

      expect(::Optimizely::Project).not_to receive(:new)
      prov.init
    end

    it "raises ProviderNotReadyError when factory fails" do
      allow(::Optimizely::Project).to receive(:new)
        .and_raise(StandardError.new("Invalid SDK key"))

      expect { provider.init }.to raise_error(
        OpenFeature::Optimizely::ProviderNotReadyError,
        /Failed to create Optimizely client/
      )
    end
  end

  describe "#shutdown" do
    it "closes the client" do
      provider.init
      expect(mock_optimizely_client).to receive(:close)
      provider.shutdown
    end

    it "does not error when client is nil" do
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
      allow(mock_optimizely_client).to receive(:create_user_context)
        .and_return(mock_user_context)
    end

    describe "#fetch_boolean_value" do
      it "returns decision.enabled for boolean flags" do
        decision = mock_decision(flag_key: flag_key, enabled: true)
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_boolean_value(
          flag_key: flag_key,
          default_value: false,
          evaluation_context: evaluation_context
        )

        expect(result).to be_a(OpenFeature::SDK::Provider::ResolutionDetails)
        expect(result.value).to eq(true)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
      end

      it "returns false when flag is disabled" do
        decision = mock_decision(flag_key: flag_key, enabled: false)
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_boolean_value(
          flag_key: flag_key,
          default_value: true,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(false)
      end

      it "returns variant from decision" do
        decision = mock_decision(flag_key: flag_key, enabled: true, variation_key: "var_a")
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_boolean_value(
          flag_key: flag_key,
          default_value: false,
          evaluation_context: evaluation_context
        )

        expect(result.variant).to eq("var_a")
      end

      it "works without evaluation context" do
        decision = mock_decision(flag_key: flag_key, enabled: true)
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_boolean_value(
          flag_key: flag_key,
          default_value: false
        )

        expect(result.value).to eq(true)
      end
    end

    describe "#fetch_string_value" do
      it "returns variable value via dotted notation" do
        decision = mock_decision(
          flag_key: "my_flag",
          enabled: true,
          variables: {"greeting" => "hello"}
        )
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_string_value(
          flag_key: "my_flag.greeting",
          default_value: "default",
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq("hello")
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
      end

      it "returns variable value via context variable_key override" do
        decision = mock_decision(
          flag_key: "my_flag",
          enabled: true,
          variables: {"greeting" => "hello"}
        )
        allow(mock_user_context).to receive(:decide).and_return(decision)

        context = OpenFeature::SDK::EvaluationContext.new(
          targeting_key: "user_123",
          variable_key: "greeting"
        )

        result = provider.fetch_string_value(
          flag_key: "my_flag",
          default_value: "default",
          evaluation_context: context
        )

        expect(result.value).to eq("hello")
      end

      it "auto-detects single string variable" do
        decision = mock_decision(
          flag_key: "my_flag",
          enabled: true,
          variables: {"greeting" => "hello"}
        )
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_string_value(
          flag_key: "my_flag",
          default_value: "default",
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq("hello")
      end

      it "returns default when flag not found" do
        allow(mock_user_context).to receive(:decide).and_return(nil)

        result = provider.fetch_string_value(
          flag_key: "missing_flag",
          default_value: "default_val",
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq("default_val")
        expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::FLAG_NOT_FOUND)
      end

      it "returns default when flag is disabled" do
        decision = mock_decision(flag_key: "my_flag", enabled: false, variables: {"x" => "y"})
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_string_value(
          flag_key: "my_flag.x",
          default_value: "default_val",
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq("default_val")
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::DISABLED)
        expect(result.error_code).to be_nil
      end
    end

    describe "#fetch_number_value" do
      it "returns numeric variable" do
        decision = mock_decision(
          flag_key: "my_flag",
          enabled: true,
          variables: {"count" => 42}
        )
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_number_value(
          flag_key: "my_flag.count",
          default_value: 0,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(42)
      end

      it "returns float variable" do
        decision = mock_decision(
          flag_key: "my_flag",
          enabled: true,
          variables: {"ratio" => 3.14}
        )
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_number_value(
          flag_key: "my_flag.ratio",
          default_value: 0.0,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(3.14)
      end
    end

    describe "#fetch_integer_value" do
      it "returns integer variable" do
        decision = mock_decision(
          flag_key: "my_flag",
          enabled: true,
          variables: {"count" => 99}
        )
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_integer_value(
          flag_key: "my_flag.count",
          default_value: 0,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(99)
      end

      it "returns type mismatch for non-integer variable" do
        decision = mock_decision(
          flag_key: "my_flag",
          enabled: true,
          variables: {"name" => "hello"}
        )
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_integer_value(
          flag_key: "my_flag.name",
          default_value: 0,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(0)
        expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::PARSE_ERROR)
      end
    end

    describe "#fetch_float_value" do
      it "returns float variable" do
        decision = mock_decision(
          flag_key: "my_flag",
          enabled: true,
          variables: {"ratio" => 2.5}
        )
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_float_value(
          flag_key: "my_flag.ratio",
          default_value: 0.0,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(2.5)
      end

      it "coerces integer to float" do
        decision = mock_decision(
          flag_key: "my_flag",
          enabled: true,
          variables: {"count" => 10}
        )
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_float_value(
          flag_key: "my_flag.count",
          default_value: 0.0,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(10.0)
        expect(result.value).to be_a(Float)
      end
    end

    describe "#fetch_object_value" do
      it "returns hash variable" do
        decision = mock_decision(
          flag_key: "my_flag",
          enabled: true,
          variables: {"config" => {"color" => "red", "size" => 42}}
        )
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_object_value(
          flag_key: "my_flag.config",
          default_value: {},
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq({"color" => "red", "size" => 42})
      end

      it "returns array variable" do
        decision = mock_decision(
          flag_key: "my_flag",
          enabled: true,
          variables: {"items" => [1, 2, 3]}
        )
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_object_value(
          flag_key: "my_flag.items",
          default_value: [],
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq([1, 2, 3])
      end
    end

    describe "auto-detection" do
      it "raises error when multiple variables match type" do
        decision = mock_decision(
          flag_key: "my_flag",
          enabled: true,
          variables: {"name" => "hello", "greeting" => "world"}
        )
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_string_value(
          flag_key: "my_flag",
          default_value: "default",
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq("default")
        expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::PARSE_ERROR)
      end

      it "raises error when no variables match type" do
        decision = mock_decision(
          flag_key: "my_flag",
          enabled: true,
          variables: {"count" => 42}
        )
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_string_value(
          flag_key: "my_flag",
          default_value: "default",
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq("default")
        expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::TYPE_MISMATCH)
      end
    end

    describe "error handling" do
      it "returns provider not ready when client is nil" do
        uninit_provider = described_class.new(configuration: configuration)

        result = uninit_provider.fetch_boolean_value(
          flag_key: "test",
          default_value: false,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(false)
        expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::PROVIDER_NOT_READY)
      end

      it "handles empty flag key" do
        result = provider.fetch_boolean_value(
          flag_key: "",
          default_value: true,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(true)
        expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::FLAG_NOT_FOUND)
      end

      it "handles nil flag key" do
        result = provider.fetch_boolean_value(
          flag_key: nil,
          default_value: true,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(true)
        expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::FLAG_NOT_FOUND)
      end

      it "handles missing variable key" do
        decision = mock_decision(
          flag_key: "my_flag",
          enabled: true,
          variables: {"other" => "value"}
        )
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_string_value(
          flag_key: "my_flag.missing_var",
          default_value: "default",
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq("default")
        expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::FLAG_NOT_FOUND)
      end

      it "handles unexpected errors" do
        allow(mock_optimizely_client).to receive(:create_user_context)
          .and_raise(StandardError.new("Connection lost"))

        result = provider.fetch_boolean_value(
          flag_key: "test",
          default_value: false,
          evaluation_context: evaluation_context
        )

        expect(result.value).to eq(false)
        expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::GENERAL)
        expect(result.error_message).to include("Connection lost")
      end

      it "uses anonymous user_id when targeting_key is nil" do
        context = OpenFeature::SDK::EvaluationContext.new
        decision = mock_decision(flag_key: "test", enabled: true)

        expect(mock_optimizely_client).to receive(:create_user_context)
          .with("anonymous", {})
          .and_return(mock_user_context)
        allow(mock_user_context).to receive(:decide).and_return(decision)

        provider.fetch_boolean_value(
          flag_key: "test",
          default_value: false,
          evaluation_context: context
        )
      end

      it "passes attributes from context fields" do
        context = OpenFeature::SDK::EvaluationContext.new(
          targeting_key: "user_123",
          plan: "premium",
          age: 25
        )
        decision = mock_decision(flag_key: "test", enabled: true)

        expect(mock_optimizely_client).to receive(:create_user_context)
          .with("user_123", {"plan" => "premium", "age" => 25})
          .and_return(mock_user_context)
        allow(mock_user_context).to receive(:decide).and_return(decision)

        provider.fetch_boolean_value(
          flag_key: "test",
          default_value: false,
          evaluation_context: context
        )
      end
    end

    describe "flag_metadata" do
      it "includes rule_key when present" do
        decision = mock_decision(
          flag_key: flag_key,
          enabled: true,
          rule_key: "experiment_1"
        )
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_boolean_value(
          flag_key: flag_key,
          default_value: false,
          evaluation_context: evaluation_context
        )

        expect(result.flag_metadata).to eq({"rule_key" => "experiment_1"})
      end

      it "returns empty metadata when rule_key is nil" do
        decision = mock_decision(flag_key: flag_key, enabled: true, rule_key: nil)
        allow(mock_user_context).to receive(:decide).and_return(decision)

        result = provider.fetch_boolean_value(
          flag_key: flag_key,
          default_value: false,
          evaluation_context: evaluation_context
        )

        expect(result.flag_metadata).to eq({})
      end
    end
  end
end
