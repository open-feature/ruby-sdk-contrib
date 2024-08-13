require "spec_helper"

RSpec.describe OpenFeature::GoFeatureFlag::GoFeatureFlagApi do
  subject(:goff_api) do
    options = OpenFeature::GoFeatureFlag::Options.new(endpoint: "http://localhost:1031")
    described_class.new(options: options)
  end

  let(:default_evaluation_context) do
    OpenFeature::SDK::EvaluationContext.new(
      targeting_key: "4f433951-4c8c-42b3-9f18-8c9a5ed8e9eb",
      company: "GO Feature Flag",
      firstname: "John",
      lastname: "Doe"
    )
  end

  context "#evaluate" do
    it "should raise an error if rate limited" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 429)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::RateLimited)
    end

    it "should raise an error if not authorized (401)" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 401)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::UnauthorizedError)
    end

    it "should raise an error if not authorized (403)" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 403)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::UnauthorizedError)
    end

    it "should raise an error if flag not found (404)" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/does-not-exists")
        .to_return(status: 404)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "does-not-exists", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::FlagNotFoundError)
    end

    it "should raise an error if unknown http code (500)" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 500)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::InternalServerError)
    end

    it "should return an error response if 400" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 400, body:
          {
            key: "double_key",
            error_code: "TYPE_MISMATCH",
            error_details: "expected type: boolean, got: string"
          }.to_json)

      got = goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      want = OpenFeature::GoFeatureFlag::OfrepApiResponse.new(
        key: "double_key",
        value: nil,
        reason: OpenFeature::SDK::Provider::Reason::ERROR,
        variant: nil,
        error_code: OpenFeature::SDK::Provider::ErrorCode::TYPE_MISMATCH,
        error_details: "expected type: boolean, got: string",
        metadata: nil
      )
      expect(got).to eql(want)
    end

    it "should return a valid response if 200" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 200, body:
          {
            key: "double_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            value: 1.15,
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      got = goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      want = OpenFeature::GoFeatureFlag::OfrepApiResponse.new(
        key: "double_key",
        value: 1.15,
        reason: OpenFeature::SDK::Provider::Reason::TARGETING_MATCH,
        variant: "variantA",
        error_code: nil,
        error_details: nil,
        metadata: {"website" => "https://gofeatureflag.org"}
      )
      expect(got).to eql(want)
    end

    it "should raise an error if 200 and json does not contains the required keys (missing value)" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 200, body:
          {
            key: "double_key",
            metadata: {"website" => "https://gofeatureflag.org"},
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::ParseError)
    end

    it "should raise an error if 200 and json does not contains the required keys (missing key)" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 200, body:
          {
            value: 1.15,
            metadata: {"website" => "https://gofeatureflag.org"},
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::ParseError)
    end

    it "should raise an error if 200 and json does not contains the required keys (missing reason)" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 200, body:
          {
            value: 1.15,
            metadata: {"website" => "https://gofeatureflag.org"},
            key: "double_key",
            variant: "variantA"
          }.to_json)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::ParseError)
    end

    it "should raise an error if 200 and json does not contains the required keys (missing variant)" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 200, body:
          {
            value: 1.15,
            metadata: {"website" => "https://gofeatureflag.org"},
            key: "double_key",
            reason: "TARGETING_MATCH"
          }.to_json)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::ParseError)
    end

    it "should raise an error if 400 and json does not contains the required keys (missing key)" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 400, body:
          {
            error_code: "TYPE_MISMATCH"
          }.to_json)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::ParseError)
    end

    it "should raise an error if 400 and json does not contains the required keys (missing error_code)" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 400, body:
          {
            key: "double_key"
          }.to_json)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::ParseError)
    end

    it "should raise an error if 400 and json does not contains the required keys (missing error_code)" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 400, body:
          {
            key: "double_key"
          }.to_json)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::ParseError)
    end

    it "should not be able to call the API again if rate-limited (with retry-after int)" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 429, headers: {"Retry-After" => "10"})

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::RateLimited)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "random_flag", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::RateLimited)
    end

    it "should be able to call the API again if we wait after the retry-after (as int)" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 429, headers: {"Retry-After" => "1"})
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/random_flag")
        .to_return(status: 200, body:
          {
            value: 1.15,
            metadata: {"website" => "https://gofeatureflag.org"},
            key: "double_key",
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::RateLimited)

      sleep(1.1)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "random_flag", evaluation_context: default_evaluation_context)
      }.not_to raise_error
    end

    it "should not be able to call the API again if rate-limited (with retry-after date)" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 429, headers: {"Retry-After" => (Time.now + 1).httpdate})

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::RateLimited)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "random_flag", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::RateLimited)
    end

    it "should be able to call the API again if we wait after the retry-after (as date)" do
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/double_key")
        .to_return(status: 429, headers: {"Retry-After" => (Time.now + 1).httpdate})
      stub_request(:post, "http://localhost:1031/ofrep/v1/evaluate/flags/random_flag")
        .to_return(status: 200, body:
          {
            value: 1.15,
            metadata: {"website" => "https://gofeatureflag.org"},
            key: "double_key",
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::RateLimited)

      sleep(1.1)

      expect {
        goff_api.evaluate_ofrep_api(flag_key: "random_flag", evaluation_context: default_evaluation_context)
      }.not_to raise_error
    end
  end
end
