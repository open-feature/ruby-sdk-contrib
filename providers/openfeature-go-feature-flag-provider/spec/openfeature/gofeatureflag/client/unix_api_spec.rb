require "spec_helper"

RSpec.describe OpenFeature::GoFeatureFlag::Client::UnixApi do
  subject(:unix_api) do
    described_class.new(endpoint: "/tmp/http.sock")
  end

  let(:default_evaluation_context) do
    OpenFeature::SDK::EvaluationContext.new(
      targeting_key: "4f433951-4c8c-42b3-9f18-8c9a5ed8e9eb",
      company: "GO Feature Flag",
      firstname: "John",
      lastname: "Doe"
    )
  end

  let(:response) { double(Net::HTTPResponse) }

  context "#evaluate" do
    it "should raise an error if rate limited" do
      allow(response).to receive(:code).and_return("429")
      allow(response).to receive(:[]).with("Retry-After").and_return(nil)
      allow(unix_api.socket).to receive(:post).and_return(response)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::RateLimited)
    end

    it "should raise an error if not authorized (401)" do
      allow(response).to receive(:code).and_return("401")
      allow(unix_api.socket).to receive(:post).and_return(response)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::UnauthorizedError)
    end

    it "should raise an error if not authorized (403)" do
      allow(response).to receive(:code).and_return("403")
      allow(unix_api.socket).to receive(:post).and_return(response)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::UnauthorizedError)
    end

    it "should raise an error if flag not found (404)" do
      allow(response).to receive(:code).and_return("404")
      allow(unix_api.socket).to receive(:post).and_return(response)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "does-not-exists", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::FlagNotFoundError)
    end

    it "should raise an error if unknown http code (500)" do
      allow(response).to receive(:code).and_return("500")
      allow(unix_api.socket).to receive(:post).and_return(response)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::InternalServerError)
    end

    it "should return an error response if 400" do
      body = {
        key: "double_key",
        error_code: "TYPE_MISMATCH",
        error_details: "expected type: boolean, got: string"
      }
      allow(response).to receive(:code).and_return("400")
      allow(response).to receive(:body).and_return(body.to_json)
      allow(unix_api.socket).to receive(:post).and_return(response)

      got = unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
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
      body = {
        key: "double_key",
        metadata: {"website" => "https://gofeatureflag.org"},
        value: 1.15,
        reason: "TARGETING_MATCH",
        variant: "variantA"
      }
      allow(response).to receive(:code).and_return("200")
      allow(response).to receive(:body).and_return(body.to_json)
      allow(unix_api.socket).to receive(:post).and_return(response)

      got = unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
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
      body = {
        key: "double_key",
        metadata: {"website" => "https://gofeatureflag.org"},
        reason: "TARGETING_MATCH",
        variant: "variantA"
      }
      allow(response).to receive(:code).and_return("200")
      allow(response).to receive(:body).and_return(body.to_json)
      allow(unix_api.socket).to receive(:post).and_return(response)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::ParseError)
    end

    it "should raise an error if 200 and json does not contains the required keys (missing key)" do
      body = {
        value: 1.15,
        metadata: {"website" => "https://gofeatureflag.org"},
        reason: "TARGETING_MATCH",
        variant: "variantA"
      }
      allow(response).to receive(:code).and_return("200")
      allow(response).to receive(:body).and_return(body.to_json)
      allow(unix_api.socket).to receive(:post).and_return(response)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::ParseError)
    end

    it "should raise an error if 200 and json does not contains the required keys (missing reason)" do
      body = {
        value: 1.15,
        metadata: {"website" => "https://gofeatureflag.org"},
        key: "double_key",
        variant: "variantA"
      }
      allow(response).to receive(:code).and_return("200")
      allow(response).to receive(:body).and_return(body.to_json)
      allow(unix_api.socket).to receive(:post).and_return(response)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::ParseError)
    end

    it "should raise an error if 200 and json does not contains the required keys (missing variant)" do
      body = {
        value: 1.15,
        metadata: {"website" => "https://gofeatureflag.org"},
        key: "double_key",
        reason: "TARGETING_MATCH"
      }
      allow(response).to receive(:code).and_return("200")
      allow(response).to receive(:body).and_return(body.to_json)
      allow(unix_api.socket).to receive(:post).and_return(response)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::ParseError)
    end

    it "should raise an error if 400 and json does not contains the required keys (missing key)" do
      body = {
        error_code: "TYPE_MISMATCH"
      }
      allow(response).to receive(:code).and_return("400")
      allow(response).to receive(:body).and_return(body.to_json)
      allow(unix_api.socket).to receive(:post).and_return(response)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::ParseError)
    end

    it "should raise an error if 400 and json does not contains the required keys (missing error_code)" do
      body = {key: "double_key"}
      allow(response).to receive(:code).and_return("400")
      allow(response).to receive(:body).and_return(body.to_json)
      allow(unix_api.socket).to receive(:post).and_return(response)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::ParseError)
    end

    it "should not be able to call the API again if rate-limited (with retry-after int)" do
      allow(response).to receive(:code).and_return("429")
      allow(response).to receive(:[]).with("Retry-After").and_return("10")
      allow(unix_api.socket).to receive(:post).and_return(response)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::RateLimited)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "random_flag", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::RateLimited)
    end

    it "should be able to call the API again if we wait after the retry-after (as int)" do
      body = {
        value: 1.15,
        metadata: {"website" => "https://gofeatureflag.org"},
        key: "double_key",
        reason: "TARGETING_MATCH",
        variant: "variantA"
      }
      allow(response).to receive(:code).and_return("429", "200")
      allow(response).to receive(:[]).with("Retry-After").and_return("1")
      allow(response).to receive(:body).and_return(body.to_json)
      allow(unix_api.socket).to receive(:post).and_return(response)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::RateLimited)

      sleep(1.1)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "random_flag", evaluation_context: default_evaluation_context)
      }.not_to raise_error
    end

    it "should not be able to call the API again if rate-limited (with retry-after date)" do
      allow(response).to receive(:code).and_return("429")
      allow(response).to receive(:[]).with("Retry-After").and_return((Time.now + 1).httpdate)
      allow(unix_api.socket).to receive(:post).and_return(response)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::RateLimited)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "random_flag", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::RateLimited)
    end

    it "should be able to call the API again if we wait after the retry-after (as date)" do
      body = {
        value: 1.15,
        metadata: {"website" => "https://gofeatureflag.org"},
        key: "double_key",
        reason: "TARGETING_MATCH",
        variant: "variantA"
      }
      allow(response).to receive(:code).and_return("429", "200")
      allow(response).to receive(:[]).with("Retry-After").and_return((Time.now + 1).httpdate)
      allow(response).to receive(:body).and_return(body.to_json)
      allow(unix_api.socket).to receive(:post).and_return(response)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "double_key", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::GoFeatureFlag::RateLimited)

      sleep(1.1)

      expect {
        unix_api.evaluate_ofrep_api(flag_key: "random_flag", evaluation_context: default_evaluation_context)
      }.not_to raise_error
    end
  end
end
