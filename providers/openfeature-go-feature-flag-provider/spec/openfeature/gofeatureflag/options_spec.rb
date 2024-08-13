require "spec_helper"

RSpec.describe OpenFeature::GoFeatureFlag::Options do
  context "#endpoint" do
    it "should have a valid endpoint set" do
      options = OpenFeature::GoFeatureFlag::Options.new(endpoint: "http://localhost:1031")
      expect(options.endpoint).to eql("http://localhost:1031")
    end

    it "should raise if endpoint is invalid" do
      expect { OpenFeature::GoFeatureFlag::Options.new(endpoint: "invalid_url") }.to raise_error(ArgumentError, "Invalid URL for endpoint: invalid_url")
    end

    it "should raise if endpoint is not http" do
      expect { OpenFeature::GoFeatureFlag::Options.new(endpoint: "ftp://gofeatureflag.org") }.to raise_error(ArgumentError, "Invalid URL for endpoint: ftp://gofeatureflag.org")
    end
  end
end
