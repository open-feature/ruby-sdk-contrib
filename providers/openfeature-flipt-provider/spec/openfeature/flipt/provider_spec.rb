# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenFeature::Flipt::Provider do
  let(:provider) { described_class.new }
  let(:client_stub) { double(::Flipt::EvaluationClient) }
  let(:evaluation_context) { {"targeting_key" => "user123", "some_key" => "some_value"} }

  before do
    allow(::Flipt::EvaluationClient).to receive(:new).and_return(client_stub)
  end

  context "2.1 - Feature Provider Interface" do
    describe "#metadata" do
      it "returns a name field which identifies the provider implementation" do
        expect(provider.metadata.name).to eq("Flipt Provider")
      end
    end
  end

  context "2.2 - Flag Value Resolution" do
    describe "#fetch_boolean_value" do
      it "returns the correct resolution details for a matching evaluation" do
        response = {
          "status" => "success",
          "result" => {"enabled" => true, "reason" => "MATCH_EVALUATION_REASON"}
        }
        allow(client_stub).to receive(:evaluate_boolean).and_return(response)

        result = provider.fetch_boolean_value(flag_key: "test_flag", default_value: false, evaluation_context: evaluation_context)
        expect(result.value).to eq(true)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
      end

      it "returns the default value for an unknown evaluation reason" do
        response = {
          "status" => "success",
          "result" => {"reason" => "UNKNOWN_EVALUATION_REASON"}
        }
        allow(client_stub).to receive(:evaluate_boolean).and_return(response)

        result = provider.fetch_boolean_value(flag_key: "test_flag", default_value: false, evaluation_context: evaluation_context)
        expect(result.value).to eq(false)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::UNKNOWN)
      end

      it "returns the default value for a flag disabled evaluation reason" do
        response = {
          "status" => "success",
          "result" => {"reason" => "FLAG_DISABLED_EVALUATION_REASON"}
        }
        allow(client_stub).to receive(:evaluate_boolean).and_return(response)

        result = provider.fetch_boolean_value(flag_key: "test_flag", default_value: false, evaluation_context: evaluation_context)
        expect(result.value).to eq(false)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::DISABLED)
      end

      it "returns the default value for an empty result" do
        response = {
          "status" => "failed",
          "result" => {}
        }
        allow(client_stub).to receive(:evaluate_boolean).and_return(response)

        result = provider.fetch_boolean_value(flag_key: "test_flag", default_value: false, evaluation_context: evaluation_context)
        expect(result.value).to eq(false)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::DEFAULT)
      end

      it "returns the default value and error message on exception" do
        allow(client_stub).to receive(:evaluate_boolean).and_raise(StandardError.new("Some error"))

        result = provider.fetch_boolean_value(flag_key: "test_flag", default_value: false, evaluation_context: evaluation_context)
        expect(result.value).to eq(false)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::ERROR)
        expect(result.error_message).to eq("Some error")
      end
    end

    describe "#fetch_string_value" do
      it "returns the correct resolution details for a matching evaluation" do
        response = {
          "status" => "success",
          "result" => {"variant_key" => "variant1", "reason" => "MATCH_EVALUATION_REASON"}
        }
        allow(client_stub).to receive(:evaluate_variant).and_return(response)

        result = provider.fetch_string_value(flag_key: "test_flag", default_value: "default", evaluation_context: evaluation_context)
        expect(result.value).to eq("variant1")
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
      end

      it "returns the default value for an unknown evaluation reason" do
        response = {
          "status" => "success",
          "result" => {"reason" => "UNKNOWN_EVALUATION_REASON"}
        }
        allow(client_stub).to receive(:evaluate_variant).and_return(response)

        result = provider.fetch_string_value(flag_key: "test_flag", default_value: "default", evaluation_context: evaluation_context)
        expect(result.value).to eq("default")
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::UNKNOWN)
      end

      it "returns the default value for a flag disabled evaluation reason" do
        response = {
          "status" => "success",
          "result" => {"reason" => "FLAG_DISABLED_EVALUATION_REASON"}
        }
        allow(client_stub).to receive(:evaluate_variant).and_return(response)

        result = provider.fetch_string_value(flag_key: "test_flag", default_value: "default", evaluation_context: evaluation_context)
        expect(result.value).to eq("default")
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::DISABLED)
      end

      it "returns the default value and error message on exception" do
        allow(client_stub).to receive(:evaluate_variant).and_raise(StandardError.new("Some error"))

        result = provider.fetch_string_value(flag_key: "test_flag", default_value: "default", evaluation_context: evaluation_context)
        expect(result.value).to eq("default")
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::ERROR)
        expect(result.error_message).to eq("Some error")
      end
    end

    describe "#fetch_number_value" do
      it "returns the correct numeric value for a matching evaluation" do
        response = {
          "status" => "success",
          "result" => {"variant_key" => "42.5", "reason" => "MATCH_EVALUATION_REASON"}
        }
        allow(client_stub).to receive(:evaluate_variant).and_return(response)

        result = provider.fetch_number_value(flag_key: "test_flag", default_value: 0, evaluation_context: evaluation_context)
        expect(result.value).to eq(42.5)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
      end

      it "returns error when value cannot be converted to number" do
        response = {
          "status" => "success",
          "result" => {"variant_key" => "not_a_number", "reason" => "MATCH_EVALUATION_REASON"}
        }
        allow(client_stub).to receive(:evaluate_variant).and_return(response)

        result = provider.fetch_number_value(flag_key: "test_flag", default_value: 0, evaluation_context: evaluation_context)
        expect(result.value).to eq(0)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::ERROR)
      end
    end

    describe "#fetch_integer_value" do
      it "returns the correct integer value for a matching evaluation" do
        response = {
          "status" => "success",
          "result" => {"variant_key" => "42", "reason" => "MATCH_EVALUATION_REASON"}
        }
        allow(client_stub).to receive(:evaluate_variant).and_return(response)

        result = provider.fetch_integer_value(flag_key: "test_flag", default_value: 0, evaluation_context: evaluation_context)
        expect(result.value).to eq(42)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
      end

      it "returns error when value cannot be converted to integer" do
        response = {
          "status" => "success",
          "result" => {"variant_key" => "42.5", "reason" => "MATCH_EVALUATION_REASON"}
        }
        allow(client_stub).to receive(:evaluate_variant).and_return(response)

        result = provider.fetch_integer_value(flag_key: "test_flag", default_value: 0, evaluation_context: evaluation_context)
        expect(result.value).to eq(0)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::ERROR)
      end
    end

    describe "#fetch_float_value" do
      it "returns the correct float value for a matching evaluation" do
        response = {
          "status" => "success",
          "result" => {"variant_key" => "42.5", "reason" => "MATCH_EVALUATION_REASON"}
        }
        allow(client_stub).to receive(:evaluate_variant).and_return(response)

        result = provider.fetch_float_value(flag_key: "test_flag", default_value: 0.0, evaluation_context: evaluation_context)
        expect(result.value).to eq(42.5)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
      end

      it "returns error when value cannot be converted to float" do
        response = {
          "status" => "success",
          "result" => {"variant_key" => "not_a_float", "reason" => "MATCH_EVALUATION_REASON"}
        }
        allow(client_stub).to receive(:evaluate_variant).and_return(response)

        result = provider.fetch_float_value(flag_key: "test_flag", default_value: 0.0, evaluation_context: evaluation_context)
        expect(result.value).to eq(0.0)
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::ERROR)
      end
    end

    describe "#fetch_object_value" do
      it "returns the correct object value for a matching evaluation" do
        response = {
          "status" => "success",
          "result" => {"variant_key" => '{"key": "value"}', "reason" => "MATCH_EVALUATION_REASON"}
        }
        allow(client_stub).to receive(:evaluate_variant).and_return(response)

        result = provider.fetch_object_value(flag_key: "test_flag", default_value: {}, evaluation_context: evaluation_context)
        expect(result.value).to eq({"key" => "value"})
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
      end

      it "returns error when value cannot be parsed as JSON" do
        response = {
          "status" => "success",
          "result" => {"variant_key" => "invalid_json", "reason" => "MATCH_EVALUATION_REASON"}
        }
        allow(client_stub).to receive(:evaluate_variant).and_return(response)

        result = provider.fetch_object_value(flag_key: "test_flag", default_value: {}, evaluation_context: evaluation_context)
        expect(result.value).to eq({})
        expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::ERROR)
      end
    end
  end

  describe "#transform_context" do
    it "transforms the context correctly" do
      result = provider.send(:transform_context, evaluation_context)
      expect(result).to eq({"some_key" => "some_value"})
    end

    it "returns an empty hash if context is nil" do
      result = provider.send(:transform_context, nil)
      expect(result).to eq({})
    end
  end
end
