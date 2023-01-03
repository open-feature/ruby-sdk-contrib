# frozen_string_literal: true

require "spec_helper"

# https://docs.openfeature.dev/docs/specification/sections/providers
RSpec.describe OpenFeature::FlagD::Provider::Client do
  subject(:client) { described_class.new }

  context "https://docs.openfeature.dev/docs/specification/sections/providers#requirement-211" do
    it do
      expect(client).to respond_to(:metadata)
      expect(client.metadata).to respond_to(:name)
      expect(client.metadata.name).to eq("Flagd Provider")
    end
  end

  context "https://docs.openfeature.dev/docs/specification/sections/providers#requirement-221" do
    it do
      expect(client).to respond_to(:resolve_boolean_value).with_keywords(:flag_key, :default_value, :context)
      expect(client).to respond_to(:resolve_integer_value).with_keywords(:flag_key, :default_value, :context)
      expect(client).to respond_to(:resolve_float_value).with_keywords(:flag_key, :default_value, :context)
      expect(client).to respond_to(:resolve_string_value).with_keywords(:flag_key, :default_value, :context)
      expect(client).to respond_to(:resolve_object_value).with_keywords(:flag_key, :default_value, :context)
    end
  end

  context "https://docs.openfeature.dev/docs/specification/sections/providers#requirement-227" do
    it do
      expect(client.resolve_boolean_value(flag_key: "some-non-existant-flag", default_value: false)).to include(
        value: nil,
        variant: nil,
        reason: "ERROR",
        error_code: "FLAG_NOT_FOUND"
      )
    end
  end
end
