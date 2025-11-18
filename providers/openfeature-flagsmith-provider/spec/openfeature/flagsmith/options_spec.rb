require "spec_helper"

RSpec.describe OpenFeature::Flagsmith::Options do
  describe "#initialize" do
    context "with valid environment_key" do
      it "should create options with required environment_key" do
        options = OpenFeature::Flagsmith::Options.new(environment_key: "test_key_123")
        expect(options.environment_key).to eq("test_key_123")
      end

      it "should use default api_url when not provided" do
        options = OpenFeature::Flagsmith::Options.new(environment_key: "test_key")
        expect(options.api_url).to eq("https://edge.api.flagsmith.com/api/v1/")
      end

      it "should use default values for optional parameters" do
        options = OpenFeature::Flagsmith::Options.new(environment_key: "test_key")
        expect(options.enable_local_evaluation).to be false
        expect(options.request_timeout_seconds).to eq(10)
        expect(options.enable_analytics).to be false
        expect(options.environment_refresh_interval_seconds).to eq(60)
      end

      it "should accept custom values for all parameters" do
        options = OpenFeature::Flagsmith::Options.new(
          environment_key: "test_key",
          api_url: "https://custom.flagsmith.com/api/v1/",
          enable_local_evaluation: true,
          request_timeout_seconds: 30,
          enable_analytics: true,
          environment_refresh_interval_seconds: 120
        )
        expect(options.environment_key).to eq("test_key")
        expect(options.api_url).to eq("https://custom.flagsmith.com/api/v1/")
        expect(options.enable_local_evaluation).to be true
        expect(options.request_timeout_seconds).to eq(30)
        expect(options.enable_analytics).to be true
        expect(options.environment_refresh_interval_seconds).to eq(120)
      end
    end

    context "environment_key validation" do
      it "should raise error when environment_key is nil" do
        expect {
          OpenFeature::Flagsmith::Options.new(environment_key: nil)
        }.to raise_error(ArgumentError, "environment_key is required and cannot be empty")
      end

      it "should raise error when environment_key is empty string" do
        expect {
          OpenFeature::Flagsmith::Options.new(environment_key: "")
        }.to raise_error(ArgumentError, "environment_key is required and cannot be empty")
      end

      it "should raise error when environment_key is whitespace only" do
        expect {
          OpenFeature::Flagsmith::Options.new(environment_key: "   ")
        }.to raise_error(ArgumentError, "environment_key is required and cannot be empty")
      end
    end

    context "api_url validation" do
      it "should accept valid http url" do
        options = OpenFeature::Flagsmith::Options.new(
          environment_key: "test_key",
          api_url: "http://localhost:8000/api/v1/"
        )
        expect(options.api_url).to eq("http://localhost:8000/api/v1/")
      end

      it "should accept valid https url" do
        options = OpenFeature::Flagsmith::Options.new(
          environment_key: "test_key",
          api_url: "https://custom.flagsmith.com/api/v1/"
        )
        expect(options.api_url).to eq("https://custom.flagsmith.com/api/v1/")
      end

      it "should raise error for invalid url" do
        expect {
          OpenFeature::Flagsmith::Options.new(
            environment_key: "test_key",
            api_url: "not_a_url"
          )
        }.to raise_error(ArgumentError, "Invalid URL for api_url: not_a_url")
      end

      it "should raise error for non-http(s) url" do
        expect {
          OpenFeature::Flagsmith::Options.new(
            environment_key: "test_key",
            api_url: "ftp://flagsmith.com"
          )
        }.to raise_error(ArgumentError, "Invalid URL for api_url: ftp://flagsmith.com")
      end
    end

    context "request_timeout_seconds validation" do
      it "should raise error for non-integer timeout" do
        expect {
          OpenFeature::Flagsmith::Options.new(
            environment_key: "test_key",
            request_timeout_seconds: "10"
          )
        }.to raise_error(ArgumentError, "request_timeout_seconds must be a positive integer")
      end

      it "should raise error for negative timeout" do
        expect {
          OpenFeature::Flagsmith::Options.new(
            environment_key: "test_key",
            request_timeout_seconds: -5
          )
        }.to raise_error(ArgumentError, "request_timeout_seconds must be a positive integer")
      end

      it "should raise error for zero timeout" do
        expect {
          OpenFeature::Flagsmith::Options.new(
            environment_key: "test_key",
            request_timeout_seconds: 0
          )
        }.to raise_error(ArgumentError, "request_timeout_seconds must be a positive integer")
      end
    end

    context "environment_refresh_interval_seconds validation" do
      it "should raise error for non-integer interval" do
        expect {
          OpenFeature::Flagsmith::Options.new(
            environment_key: "test_key",
            environment_refresh_interval_seconds: "60"
          )
        }.to raise_error(ArgumentError, "environment_refresh_interval_seconds must be a positive integer")
      end

      it "should raise error for negative interval" do
        expect {
          OpenFeature::Flagsmith::Options.new(
            environment_key: "test_key",
            environment_refresh_interval_seconds: -10
          )
        }.to raise_error(ArgumentError, "environment_refresh_interval_seconds must be a positive integer")
      end
    end
  end

  describe "#local_evaluation?" do
    it "should return false when local evaluation is disabled" do
      options = OpenFeature::Flagsmith::Options.new(
        environment_key: "test_key",
        enable_local_evaluation: false
      )
      expect(options.local_evaluation?).to be false
    end

    it "should return true when local evaluation is enabled" do
      options = OpenFeature::Flagsmith::Options.new(
        environment_key: "test_key",
        enable_local_evaluation: true
      )
      expect(options.local_evaluation?).to be true
    end
  end

  describe "#analytics_enabled?" do
    it "should return false when analytics is disabled" do
      options = OpenFeature::Flagsmith::Options.new(
        environment_key: "test_key",
        enable_analytics: false
      )
      expect(options.analytics_enabled?).to be false
    end

    it "should return true when analytics is enabled" do
      options = OpenFeature::Flagsmith::Options.new(
        environment_key: "test_key",
        enable_analytics: true
      )
      expect(options.analytics_enabled?).to be true
    end
  end
end
