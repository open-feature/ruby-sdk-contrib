# frozen_string_literal: true

require "spec_helper"

# https://openfeature.dev/docs/specification/sections/providers
RSpec.describe OpenFeature::Flagd::Provider::Client do
  let(:configuration) { OpenFeature::Flagd::Provider::Configuration.default_config }
  subject(:client) { described_class.new(configuration: configuration) }

  context "https://openfeature.dev/docs/specification/sections/providers#requirement-211" do
    it do
      expect(client).to respond_to(:metadata)
      expect(client.metadata).to respond_to(:name)
      expect(client.metadata.name).to eq("flagd Provider")
    end
  end

  context "https://openfeature.dev/docs/specification/sections/providers#requirement-221|222" do
    it do
      expect(client).to respond_to(:fetch_boolean_value).with_keywords(:flag_key, :default_value, :evaluation_context)
      expect(client).to respond_to(:fetch_integer_value).with_keywords(:flag_key, :default_value, :evaluation_context)
      expect(client).to respond_to(:fetch_float_value).with_keywords(:flag_key, :default_value, :evaluation_context)
      expect(client).to respond_to(:fetch_string_value).with_keywords(:flag_key, :default_value, :evaluation_context)
      expect(client).to respond_to(:fetch_object_value).with_keywords(:flag_key, :default_value, :evaluation_context)
    end
  end

  context "https://openfeature.dev/docs/specification/sections/providers#requirement-223|224|225|226" do
    it do
      expect(client.fetch_boolean_value(flag_key: "boolean-flag", default_value: false).to_h).to include(
        error_code: nil,
        error_message: nil,
        reason: "STATIC",
        value: false,
        variant: "off"
      )
    end

    it do
      expect(client.fetch_integer_value(flag_key: "integer-flag", default_value: 1).to_h).to include(
        error_code: nil,
        error_message: nil,
        reason: "STATIC",
        value: 42,
        variant: "fourty-two"
      )
    end

    it do
      expect(client.fetch_float_value(flag_key: "float-flag", default_value: 1.1).to_h).to include(
        error_code: nil,
        error_message: nil,
        reason: "STATIC",
        value: 4.2,
        variant: "four-point-two"
      )
    end

    it do
      expect(client.fetch_string_value(flag_key: "string-flag", default_value: "lololo").to_h).to include(
        error_code: nil,
        error_message: nil,
        reason: "STATIC",
        value: "lalala",
        variant: "lilili"
      )
    end

    it do
      resolution_details = client.fetch_object_value(flag_key: "object-flag", default_value: {"a" => "b"})
      expect(resolution_details.to_h).to include(
        error_code: nil,
        error_message: nil,
        reason: "STATIC",
        variant: "real-object"
      )
      expect(resolution_details[:value].fields["real"].string_value).to eq("value")
    end
  end

  context "https://openfeature.dev/docs/specification/sections/providers#requirement-227" do
    it do
      expect(client.fetch_boolean_value(flag_key: "some-non-existant-flag", default_value: false).to_h).to include(
        value: false,
        variant: nil,
        reason: "ERROR",
        error_code: "FLAG_NOT_FOUND"
      )
    end
  end
end
