# frozen_string_literal: true

# Shared examples for OpenFeature provider conformance testing.
#
# Usage:
#   require_relative "path/to/shared_config/conformance/provider_shared_examples.rb"
#
#   RSpec.describe MyProvider do
#     let(:provider) { MyProvider.new(...) }
#
#     it_behaves_like "an OpenFeature provider"
#   end

RSpec.shared_examples "an OpenFeature provider" do
  describe "provider interface conformance" do
    it "exposes metadata with a non-empty name" do
      expect(provider).to respond_to(:metadata)
      expect(provider.metadata).to respond_to(:name)
      expect(provider.metadata.name).to be_a(String)
      expect(provider.metadata.name).not_to be_empty
    end

    it "responds to fetch_boolean_value with keyword arguments" do
      expect(provider).to respond_to(:fetch_boolean_value)

      method = provider.method(:fetch_boolean_value)
      param_names = method.parameters.map(&:last)
      expect(param_names).to include(:flag_key, :default_value)
    end

    it "responds to fetch_string_value with keyword arguments" do
      expect(provider).to respond_to(:fetch_string_value)

      method = provider.method(:fetch_string_value)
      param_names = method.parameters.map(&:last)
      expect(param_names).to include(:flag_key, :default_value)
    end

    it "responds to fetch_number_value with keyword arguments" do
      expect(provider).to respond_to(:fetch_number_value)

      method = provider.method(:fetch_number_value)
      param_names = method.parameters.map(&:last)
      expect(param_names).to include(:flag_key, :default_value)
    end

    it "responds to fetch_object_value with keyword arguments" do
      expect(provider).to respond_to(:fetch_object_value)

      method = provider.method(:fetch_object_value)
      param_names = method.parameters.map(&:last)
      expect(param_names).to include(:flag_key, :default_value)
    end
  end
end

RSpec.shared_examples "an OpenFeature provider with integer and float support" do
  it "responds to fetch_integer_value with keyword arguments" do
    expect(provider).to respond_to(:fetch_integer_value)

    method = provider.method(:fetch_integer_value)
    param_names = method.parameters.map(&:last)
    expect(param_names).to include(:flag_key, :default_value)
  end

  it "responds to fetch_float_value with keyword arguments" do
    expect(provider).to respond_to(:fetch_float_value)

    method = provider.method(:fetch_float_value)
    param_names = method.parameters.map(&:last)
    expect(param_names).to include(:flag_key, :default_value)
  end
end
