require "spec_helper"

RSpec.describe OpenFeature::GoFeatureFlag::Provider do
  subject(:goff_provider) do
    options = OpenFeature::GoFeatureFlag::Options.new(endpoint: "http://localhost:1031")
    described_class.new(options: options)
  end

  context "#metadata" do
    it "metadata name is defined" do
      expect(goff_provider).to respond_to(:metadata)
      expect(goff_provider.metadata).to respond_to(:name)
      expect(goff_provider.metadata.name).to eq("GO Feature Flag Provider")
    end
  end

  context "#options" do
    it "should have a valid endpoint set" do
      expect(goff_provider.options.endpoint).to eql("http://localhost:1031")
    end

    it "should raise if endpoint is invalid" do
      expect { OpenFeature::GoFeatureFlag::Options.new(endpoint: "invalid_url") }.to raise_error(ArgumentError, "Invalid URL for endpoint: invalid_url")
    end

    it "should raise if endpoint is not http" do
      expect { OpenFeature::GoFeatureFlag::Options.new(endpoint: "ftp://gofeatureflag.org") }.to raise_error(ArgumentError, "Invalid URL for endpoint: ftp://gofeatureflag.org")
    end
  end

  context "#fetch_boolean_value with openfeature" do
    it "should return the value of the flag" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 200, body:
          {
            key: "double_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            value: true,
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_boolean_details(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "boolean_flag",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: true,
          reason: OpenFeature::SDK::Provider::Reason::TARGETING_MATCH,
          variant: "variantA",
          flag_metadata: {"website" => "https://gofeatureflag.org"}
        )
      )
      expect(got).to eql(want)
    end

    it "should return the default value if flag is not the right type" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 200, body:
          {
            key: "double_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            value: "default",
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_boolean_details(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
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

    it "should return the default value of the flag if error send by the API (http code 403)" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 403)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_boolean_details(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
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

    it "should return the default value of the flag if error send by the API (http code 400)" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 400, body:
          {
            key: "double_key",
            error_code: "INVALID_CONTEXT"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_boolean_details(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
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

    it "should return default value if no evaluation context" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 200, body:
          {
            key: "double_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            value: true,
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_boolean_details(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: nil
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "boolean_flag",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: false,
          reason: OpenFeature::SDK::Provider::Reason::ERROR,
          error_code: OpenFeature::SDK::Provider::ErrorCode::INVALID_CONTEXT,
          error_message: "invalid evaluation context provided"
        )
      )
      expect(got).to eql(want)
    end

    it "should return default value if evaluation context has empty string targetingKey" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 200, body:
          {
            key: "double_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            value: true,
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_boolean_details(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "boolean_flag",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: false,
          reason: OpenFeature::SDK::Provider::Reason::ERROR,
          error_code: OpenFeature::SDK::Provider::ErrorCode::INVALID_CONTEXT,
          error_message: "invalid evaluation context provided"
        )
      )
      expect(got).to eql(want)
    end

    it "should return default value if evaluation context has nil targetingKey" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 200, body:
          {
            key: "double_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            value: true,
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_boolean_details(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: nil)
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "boolean_flag",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: false,
          reason: OpenFeature::SDK::Provider::Reason::ERROR,
          error_code: OpenFeature::SDK::Provider::ErrorCode::INVALID_CONTEXT,
          error_message: "invalid evaluation context provided"
        )
      )
      expect(got).to eql(want)
    end

    it "should return default value if flag_key nil" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 200, body:
          {
            key: "double_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            value: true,
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_boolean_details(
        flag_key: nil,
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "1234")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: nil,
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: false,
          reason: OpenFeature::SDK::Provider::Reason::ERROR,
          error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL,
          error_message: "invalid flag key provided"
        )
      )
      expect(got).to eql(want)
    end

    it "should return default value if flag_key empty string" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 200, body:
          {
            key: "double_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            value: true,
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_boolean_details(
        flag_key: "",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "1234")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: false,
          reason: OpenFeature::SDK::Provider::Reason::ERROR,
          error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL,
          error_message: "invalid flag key provided"
        )
      )
      expect(got).to eql(want)
    end
  end

  context "#fetch_string_value with openfeature" do
    it "should return the value of the flag" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/flag_key")
        .to_return(status: 200, body:
          {
            key: "flag_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            value: "aValue",
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_string_details(
        flag_key: "flag_key",
        default_value: "default",
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "flag_key",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: "aValue",
          variant: "variantA",
          reason: OpenFeature::SDK::Provider::Reason::TARGETING_MATCH,
          flag_metadata: {"website" => "https://gofeatureflag.org"}
        )
      )
      expect(got).to eql(want)
    end

    it "should return the default value if flag is not the right type" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/flag_key")
        .to_return(status: 200, body:
          {
            key: "flag_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            value: 15,
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_string_details(
        flag_key: "flag_key",
        default_value: "default",
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "flag_key",
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

  context "#fetch_number_value with openfeature" do
    it "should return the value of the flag" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/flag_key")
        .to_return(status: 200, body:
          {
            key: "flag_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            value: 15,
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_number_details(
        flag_key: "flag_key",
        default_value: 25,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "flag_key",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: 15,
          variant: "variantA",
          reason: OpenFeature::SDK::Provider::Reason::TARGETING_MATCH,
          flag_metadata: {"website" => "https://gofeatureflag.org"}
        )
      )
      expect(got).to eql(want)
    end

    it "should return the default value if flag is not the right type" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/flag_key")
        .to_return(status: 200, body:
          {
            key: "flag_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            value: "yoyo",
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_number_details(
        flag_key: "flag_key",
        default_value: 25,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "flag_key",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: 25,
          reason: OpenFeature::SDK::Provider::Reason::ERROR,
          error_code: OpenFeature::SDK::Provider::ErrorCode::TYPE_MISMATCH,
          error_message: "flag type String does not match allowed types [Integer, Float]"
        )
      )
      expect(got).to eql(want)
    end
  end

  context "#fetch_object_value with openfeature" do
    it "should return the value of the flag" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/flag_key")
        .to_return(status: 200, body:
          {
            key: "flag_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            value: {"test" => "test"},
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_object_details(
        flag_key: "flag_key",
        default_value: {"fail" => true},
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "flag_key",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: {"test" => "test"},
          variant: "variantA",
          reason: OpenFeature::SDK::Provider::Reason::TARGETING_MATCH,
          flag_metadata: {"website" => "https://gofeatureflag.org"}
        )
      )
      expect(got).to eql(want)
    end

    it "should return the default value if flag is not the right type" do
      test_name = RSpec.current_example.description
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/flag_key")
        .to_return(status: 200, body:
          {
            key: "flag_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            value: '{"test" => "test"}',
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      got = client.fetch_object_details(
        flag_key: "flag_key",
        default_value: {"fail" => true},
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
      )
      want = OpenFeature::SDK::EvaluationDetails.new(
        flag_key: "flag_key",
        resolution_details: OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: {"fail" => true},
          reason: OpenFeature::SDK::Provider::Reason::ERROR,
          error_code: OpenFeature::SDK::Provider::ErrorCode::TYPE_MISMATCH,
          error_message: "flag type String does not match allowed types [Array, Hash]"
        )
      )
      expect(got).to eql(want)
    end
  end

  context "#fetch_boolean_value provider directly" do
    it "should return an error if no evaluation context" do
      eval = goff_provider.fetch_boolean_value(flag_key: "flag_key", default_value: true, evaluation_context: nil)
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: true,
        error_code: OpenFeature::SDK::Provider::ErrorCode::INVALID_CONTEXT,
        error_message: "invalid evaluation context provided",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval).to eql(want)
    end

    it "should return an error if evaluation context has empty string targetingKey" do
      eval = goff_provider.fetch_boolean_value(flag_key: "flag_key",
        default_value: true,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: ""))
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: true,
        error_code: OpenFeature::SDK::Provider::ErrorCode::INVALID_CONTEXT,
        error_message: "invalid evaluation context provided",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval).to eql(want)
    end

    it "should return an error if evaluation context has nil targetingKey" do
      eval = goff_provider.fetch_boolean_value(flag_key: "flag_key",
        default_value: true,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: nil))
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: true,
        error_code: OpenFeature::SDK::Provider::ErrorCode::INVALID_CONTEXT,
        error_message: "invalid evaluation context provided",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval).to eql(want)
    end

    it "should return an error if flag_key nil" do
      eval = goff_provider.fetch_boolean_value(flag_key: nil,
        default_value: true,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16"))
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: true,
        error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL,
        error_message: "invalid flag key provided",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval).to eql(want)
    end

    it "should return an error if flag_key empty string" do
      eval = goff_provider.fetch_boolean_value(flag_key: "",
        default_value: true,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16"))
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: true,
        error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL,
        error_message: "invalid flag key provided",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval).to eql(want)
    end

    it "return an error API response if 401" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 401)
      eval = goff_provider.fetch_boolean_value(
        flag_key: "boolean_flag",
        default_value: true,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
      )
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: true,
        error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL,
        error_message: "unauthorized",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval).to eql(want)
    end

    it "return an error API response if 403" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 403)
      eval = goff_provider.fetch_boolean_value(
        flag_key: "boolean_flag",
        default_value: true,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
      )
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: true,
        error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL,
        error_message: "unauthorized",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval).to eql(want)
    end

    it "return an error API response if 400" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 400, body:
          {
            key: "boolean_flag",
            error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL.to_s,
            error_details: "GENERAL error"
          }.to_json)
      eval = goff_provider.fetch_boolean_value(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
      )
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: false,
        error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL,
        error_message: "GENERAL error",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval).to eql(want)
    end

    it "return an error API response if flag not found 404" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 404, body:
          {
            key: "boolean_flag",
            error_code: OpenFeature::SDK::Provider::ErrorCode::FLAG_NOT_FOUND.to_s,
            error_details: "GENERAL error"
          }.to_json)
      eval = goff_provider.fetch_boolean_value(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
      )
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: false,
        error_code: OpenFeature::SDK::Provider::ErrorCode::FLAG_NOT_FOUND,
        error_message: "Flag not found: boolean_flag",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval).to eql(want)
    end

    it "return an error API response if 500" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/boolean_flag")
        .to_return(status: 500, body:
          {
            key: "boolean_flag",
            error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL.to_s,
            error_details: "GENERAL error"
          }.to_json)
      eval = goff_provider.fetch_boolean_value(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
      )
      want = OpenFeature::SDK::Provider::ResolutionDetails.new(
        value: false,
        error_code: OpenFeature::SDK::Provider::ErrorCode::GENERAL,
        error_message: "Internal Server Error",
        reason: OpenFeature::SDK::Provider::Reason::ERROR
      )
      expect(eval).to eql(want)
    end
  end

  context "#exporter_metadata" do
    it "should send exporter_metadata in the API if set in provider" do
      test_name = RSpec.current_example.description
      request_body = nil
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/boolean_flag")
        .with { |req| request_body = req.body }
        .to_return(status: 200, body:
          {
            key: "double_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            value: true,
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      options = OpenFeature::GoFeatureFlag::Options.new(endpoint: "http://localhost:1031", exporter_metadata: {
        "key1" => "value1",
        "key2" => 123,
        "key3" => 123.45
      })
      goff_test_provider = OpenFeature::GoFeatureFlag::Provider.new(options: options)

      OpenFeature::SDK.configure do |config|
        config.set_provider(goff_test_provider, domain: test_name)
      end
      client = OpenFeature::SDK.build_client(domain: test_name)
      client.fetch_boolean_details(
        flag_key: "boolean_flag",
        default_value: false,
        evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")
      )
      got = JSON.parse(request_body)
      want = JSON.parse('{"context":{"gofeatureflag":{"exporterMetadata":{"key1":"value1","openfeature":true,"provider":"ruby", "key2": 123, "key3":123.45}},"targetingKey":"9b9450f8-ab5c-4dcf-872f-feda3f6ccb16"}}')
      expect(got).to eql(want)
    end
  end
end
