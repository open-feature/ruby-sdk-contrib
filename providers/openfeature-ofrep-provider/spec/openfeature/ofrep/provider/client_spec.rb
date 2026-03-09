# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenFeature::OFREP::Client do
  subject(:client) do
    config = OpenFeature::OFREP::Configuration.new(base_url: "http://localhost:8080")
    described_class.new(configuration: config)
  end

  let(:default_evaluation_context) do
    OpenFeature::SDK::EvaluationContext.new(
      targeting_key: "4f433951-4c8c-42b3-9f18-8c9a5ed8e9eb",
      company: "OFREP",
      firstname: "John",
      lastname: "Doe"
    )
  end

  context "#evaluate" do
    it "returns a valid response if 200" do
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/my_flag")
        .to_return(status: 200, body:
          {
            key: "my_flag",
            metadata: {"source" => "database"},
            value: true,
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      got = client.evaluate(flag_key: "my_flag", evaluation_context: default_evaluation_context)
      want = OpenFeature::OFREP::Response.new(
        key: "my_flag",
        value: true,
        reason: OpenFeature::SDK::Provider::Reason::TARGETING_MATCH,
        variant: "variantA",
        error_code: nil,
        error_details: nil,
        metadata: {"source" => "database"}
      )
      expect(got).to eql(want)
    end

    it "returns an error response if 400" do
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/my_flag")
        .to_return(status: 400, body:
          {
            key: "my_flag",
            error_code: "TYPE_MISMATCH",
            error_details: "expected type: boolean, got: string"
          }.to_json)

      got = client.evaluate(flag_key: "my_flag", evaluation_context: default_evaluation_context)
      want = OpenFeature::OFREP::Response.new(
        key: "my_flag",
        value: nil,
        reason: OpenFeature::SDK::Provider::Reason::ERROR,
        variant: nil,
        error_code: OpenFeature::SDK::Provider::ErrorCode::TYPE_MISMATCH,
        error_details: "expected type: boolean, got: string",
        metadata: nil
      )
      expect(got).to eql(want)
    end

    it "raises an error if not authorized (401)" do
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/my_flag")
        .to_return(status: 401)

      expect {
        client.evaluate(flag_key: "my_flag", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::OFREP::UnauthorizedError)
    end

    it "raises an error if not authorized (403)" do
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/my_flag")
        .to_return(status: 403)

      expect {
        client.evaluate(flag_key: "my_flag", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::OFREP::UnauthorizedError)
    end

    it "raises an error if flag not found (404)" do
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/does-not-exist")
        .to_return(status: 404)

      expect {
        client.evaluate(flag_key: "does-not-exist", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::OFREP::FlagNotFoundError)
    end

    it "raises an error if rate limited (429)" do
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/my_flag")
        .to_return(status: 429)

      expect {
        client.evaluate(flag_key: "my_flag", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::OFREP::RateLimited)
    end

    it "raises an error if server error (500)" do
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/my_flag")
        .to_return(status: 500)

      expect {
        client.evaluate(flag_key: "my_flag", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::OFREP::InternalServerError)
    end

    it "raises a parse error if 200 and missing required keys" do
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/my_flag")
        .to_return(status: 200, body:
          {
            key: "my_flag",
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      expect {
        client.evaluate(flag_key: "my_flag", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::OFREP::ParseError)
    end

    it "raises a parse error if 400 and missing required keys" do
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/my_flag")
        .to_return(status: 400, body:
          {
            error_code: "TYPE_MISMATCH"
          }.to_json)

      expect {
        client.evaluate(flag_key: "my_flag", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::OFREP::ParseError)
    end

    it "blocks subsequent calls when rate limited with Retry-After header (integer)" do
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/my_flag")
        .to_return(status: 429, headers: {"Retry-After" => "10"})

      expect {
        client.evaluate(flag_key: "my_flag", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::OFREP::RateLimited)

      expect {
        client.evaluate(flag_key: "other_flag", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::OFREP::RateLimited)
    end

    it "allows calls again after Retry-After period expires (integer)" do
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/my_flag")
        .to_return(status: 429, headers: {"Retry-After" => "1"})
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/other_flag")
        .to_return(status: 200, body:
          {
            key: "other_flag",
            value: true,
            reason: "TARGETING_MATCH",
            variant: "variantA"
          }.to_json)

      expect {
        client.evaluate(flag_key: "my_flag", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::OFREP::RateLimited)

      sleep(1.1)

      expect {
        client.evaluate(flag_key: "other_flag", evaluation_context: default_evaluation_context)
      }.not_to raise_error
    end

    it "blocks subsequent calls when rate limited with Retry-After header (date)" do
      stub_request(:post, "http://localhost:8080/ofrep/v1/evaluate/flags/my_flag")
        .to_return(status: 429, headers: {"Retry-After" => (Time.now + 1).httpdate})

      expect {
        client.evaluate(flag_key: "my_flag", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::OFREP::RateLimited)

      expect {
        client.evaluate(flag_key: "other_flag", evaluation_context: default_evaluation_context)
      }.to raise_error(OpenFeature::OFREP::RateLimited)
    end
  end
end
