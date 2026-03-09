# frozen_string_literal: true

require "spec_helper"
require_relative "../../../../../shared_config/conformance/provider_shared_examples"

RSpec.describe OpenFeature::OFREP::Provider do
  subject(:ofrep_provider) do
    configuration = OpenFeature::OFREP::Configuration.new(base_url: "http://localhost:8080")
    described_class.new(configuration: configuration)
  end

  describe "conformance" do
    let(:provider) { ofrep_provider }

    it_behaves_like "an OpenFeature provider"
    it_behaves_like "an OpenFeature provider with integer and float support"
  end

  context "#metadata" do
    it "metadata name is defined" do
      expect(ofrep_provider).to respond_to(:metadata)
      expect(ofrep_provider.metadata).to respond_to(:name)
      expect(ofrep_provider.metadata.name).to eq("OFREP Provider")
    end
  end

  context "#fetch_boolean_value" do
    it "returns the value of the flag" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 200, body:
          {
            key: "boolean_flag",
            metadata: {"source" => "database"},
            value: true,
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(ofrep_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_boolean_details(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "boolean_flag",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: true,
          reason: OpenFeature::SDK::Provider::Reason::TARGETING_MATCH,
          variant: "variantA",
          flag_metadata: {"source" => "database"}
        )
      )
      expect(got).to eql(want)
    end

    it "returns the default value if flag is not the right type" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 200, body:
          {
            key: "boolean_flag",
            value: "not_a_boolean",
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(ofrep_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_boolean_details(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "boolean_flag",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: false,
          reason: OpenFeature::SDK::Provider::Reason::ERROR,
          error_code: OpenFeature::SDK::Provider::ErrorCode::TYPE_MISMATCH,
          error_message: "flag type String does not match allowed types [TrueClass, FalseClass]"
        )
      )
      expect(got).to eql(want)
    end

    it "returns the default value if error send by the API (http code 403)" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 403)

      OpenFeature::SDK.configure do |config|
        config.set_provider(ofrep_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_boolean_details(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "boolean_flag",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: false,
          reason: OpenFeature::SDK::Provider::Reason::ERROR,
          error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL,
          error_message: "unauthorized"
        )
      )
      expect(got).to eql(want)
    end

    it "returns the default value if error send by the API (http code 400)" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 400, body:
          {
            key: "boolean_flag",
            error_code: "INVALID_CONTEXT"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(ofrep_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_boolean_details(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "boolean_flag",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: false,
          reason: OpenFeature::SDK::Provider::Reason::ERROR,
          error_code: OpenFeature::SDK::Provider::ErrorCode::INVALID_CONTEXT
        )
      )
      expect(got).to eql(want)
    end

    it "returns default value if no evaluation context" do
      eval_result = ofrep_provider.fetch_boolean_value(flag_key: "flag_key", default_value: true, evaluation_context: nil)
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: true,
        error_code: OpenFeature::SDK::Provider::ErrorCode::INVALID_CONTEXT,
        error_message: "invalid evaluation context provided",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval_result).to eql(want)
    end

    it "returns default value if evaluation context has empty targeting key" do
      eval_result = ofrep_provider.fetch_boolean_value(
        flag_key: "flag_key",
        default_value: true,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "")
      )
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: true,
        error_code: OpenFeature::SDK::Provider::ErrorCode::INVALID_CONTEXT,
        error_message: "invalid evaluation context provided",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval_result).to eql(want)
    end

    it "returns default value if flag_key is nil" do
      eval_result = ofrep_provider.fetch_boolean_value(
        flag_key: nil,
        default_value: true,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: true,
        error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL,
        error_message: "invalid flag key provided",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval_result).to eql(want)
    end

    it "returns default value if flag_key is empty" do
      eval_result = ofrep_provider.fetch_boolean_value(
        flag_key: "",
        default_value: true,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: true,
        error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL,
        error_message: "invalid flag key provided",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval_result).to eql(want)
    end

    it "returns the default value if the reason is DISABLED" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 200, body:
          {
            key: "boolean_flag",
            value: true,
            reason: "DISABLED",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(ofrep_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_boolean_details(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "boolean_flag",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: false,
          reason: OpenFeature::SDK::Provider::Reason::DISABLED
        )
      )
      expect(got).to eql(want)
    end

    it "returns error for 404 flag not found" do
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/missing_flag")
        .to_return(status: 404)

      eval_result = ofrep_provider.fetch_boolean_value(
        flag_key: "missing_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: false,
        error_code: OpenFeature::SDK::Provider::ErrorCode::FLAG_NOT_FOUND,
        error_message: "Flag not found: missing_flag",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval_result).to eql(want)
    end

    it "returns error for 401 unauthorized" do
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 401)

      eval_result = ofrep_provider.fetch_boolean_value(
        flag_key: "boolean_flag",
        default_value: true,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: true,
        error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL,
        error_message: "unauthorized",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval_result).to eql(want)
    end

    it "returns error for 500 server error" do
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 500)

      eval_result = ofrep_provider.fetch_boolean_value(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: false,
        error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL,
        error_message: "Internal Server Error",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval_result).to eql(want)
    end
  end

  context "#fetch_string_value" do
    it "returns the value of the flag" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/string_flag")
        .to_return(status: 200, body:
          {
            key: "string_flag",
            value: "hello",
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(ofrep_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_string_details(
        flag_key: "string_flag",
        default_value: "default",
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "string_flag",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: "hello",
          variant: "variantA",
          reason: OpenFeature::SDK::Provider::Reason::TARGETING_MATCH
        )
      )
      expect(got).to eql(want)
    end

    it "returns the default value if flag is not the right type" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/string_flag")
        .to_return(status: 200, body:
          {
            key: "string_flag",
            value: 42,
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(ofrep_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_string_details(
        flag_key: "string_flag",
        default_value: "default",
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "string_flag",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: "default",
          reason: OpenFeature::SDK::Provider::Reason::ERROR,
          error_code: OpenFeature::SDK::Provider::ErrorCode::TYPE_MISMATCH,
          error_message: "flag type Integer does not match allowed types [String]"
        )
      )
      expect(got).to eql(want)
    end
  end

  context "#fetch_number_value" do
    it "returns the value of the flag" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/number_flag")
        .to_return(status: 200, body:
          {
            key: "number_flag",
            value: 42,
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(ofrep_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_number_details(
        flag_key: "number_flag",
        default_value: 0,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "number_flag",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: 42,
          variant: "variantA",
          reason: OpenFeature::SDK::Provider::Reason::TARGETING_MATCH
        )
      )
      expect(got).to eql(want)
    end

    it "returns the default value if flag is not the right type" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/number_flag")
        .to_return(status: 200, body:
          {
            key: "number_flag",
            value: "not_a_number",
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(ofrep_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_number_details(
        flag_key: "number_flag",
        default_value: 0,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "number_flag",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: 0,
          reason: OpenFeature::SDK::Provider::Reason::ERROR,
          error_code: OpenFeature::SDK::Provider::ErrorCode::TYPE_MISMATCH,
          error_message: "flag type String does not match allowed types [Integer, Float]"
        )
      )
      expect(got).to eql(want)
    end
  end

  context "#fetch_object_value" do
    it "returns the value of the flag" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/object_flag")
        .to_return(status: 200, body:
          {
            key: "object_flag",
            value: {"color" => "blue"},
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(ofrep_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_object_details(
        flag_key: "object_flag",
        default_value: {},
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "object_flag",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: {"color" => "blue"},
          variant: "variantA",
          reason: OpenFeature::SDK::Provider::Reason::TARGETING_MATCH
        )
      )
      expect(got).to eql(want)
    end

    it "returns the default value if flag is not the right type" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/object_flag")
        .to_return(status: 200, body:
          {
            key: "object_flag",
            value: "not_an_object",
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(ofrep_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_object_details(
        flag_key: "object_flag",
        default_value: {"fallback" => true},
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "object_flag",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: {"fallback" => true},
          reason: OpenFeature::SDK::Provider::Reason::ERROR,
          error_code: OpenFeature::SDK::Provider::ErrorCode::TYPE_MISMATCH,
          error_message: "flag type String does not match allowed types [Array, Hash]"
        )
      )
      expect(got).to eql(want)
    end
  end
end
