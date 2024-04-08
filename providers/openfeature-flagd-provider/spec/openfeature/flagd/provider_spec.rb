# frozen_string_literal: true

require "spec_helper"
require "open_feature/sdk"

# https://openfeature.dev/docs/specification/sections/providers

RSpec.describe OpenFeature::FlagD::Provider do
  before do
    ENV["FLAGD_HOST"] = nil
    ENV["FLAGD_PORT"] = nil
    ENV["FLAGD_TLS"] = nil
  end

  subject(:flagd_client) { described_class.build_client }

  context "#configure" do
    context "when defining host, port and tls options of gRPC service it wishes to access with configure method" do
      subject(:explicit_configuration) do
        flagd_client.configure do |config|
          config.host = explicit_host
          config.port = explicit_port
          config.tls = explicit_tls
        end
      end

      let(:explicit_host) { "explicit_host" }
      let(:explicit_port) { 8013 }
      let(:explicit_tls) { false }

      it "expects configuration to be values set from configure method" do
        explicit_configuration
        expect(flagd_client.configuration.host).to eq(explicit_host)
        expect(flagd_client.configuration.port).to eq(explicit_port)
        expect(flagd_client.configuration.tls).to eq(explicit_tls)
      end

      context "when defining environment variables" do
        before do
          ENV["FLAGD_HOST"] = "172.16.1.2"
          ENV["FLAGD_PORT"] = "8014"
          ENV["FLAGD_TLS"] = "true"
        end

        it "uses the explicit configuration" do
          explicit_configuration
          expect(flagd_client.configuration.host).to eq(explicit_host)
          expect(flagd_client.configuration.port).to eq(explicit_port)
          expect(flagd_client.configuration.tls).to eq(explicit_tls)
        end
      end
    end

    context "when defining environment variables" do
      let(:env_host) { "172.16.1.2" }
      let(:env_port) { "8014" }
      let(:env_tls) { "true" }
      subject(:env_configuration) do
        ENV["FLAGD_HOST"] = env_host
        ENV["FLAGD_PORT"] = env_port
        ENV["FLAGD_TLS"] = env_tls
        flagd_client.configuration
      end

      it "uses environment variables when no explicit configuration" do
        env_configuration
        expect(env_configuration.host).to eq(env_host)
        expect(env_configuration.port).to eq(env_port.to_i)
        expect(env_configuration.tls).to eq(env_tls == "true")
      end
    end
  end

  # https://openfeature.dev/docs/specification/sections/providers#requirement-211
  context "#metadata" do
    it "metadata name is defined" do
      expect(flagd_client).to respond_to(:metadata)
      expect(flagd_client.metadata).to respond_to(:name)
      expect(flagd_client.metadata.name).to eq("flagd Provider")
    end
  end

  context "OpenFeature SDK integration" do
    before do
      OpenFeature::SDK.configure do |config|
        config.set_provider(OpenFeature::FlagD::Provider.build_client)
      end
    end
    subject(:client) { OpenFeature::SDK.build_client }

    context "get value" do
      it do
        expect(client.fetch_boolean_value(flag_key: 'boolean-flag', default_value: false)).to be_falsy
      end

      it do
        expect(client.fetch_number_value(flag_key: "integer-flag", default_value: 1)).to eq(42)
      end

      it do
        expect(client.fetch_number_value(flag_key: "float-flag", default_value: 1.1)).to eq(4.2)
      end

      it do
        expect(client.fetch_string_value(flag_key: "string-flag", default_value: "lololo")).to eq("lalala")
      end

      it do
        expect(client.fetch_object_value(flag_key: "object-flag", default_value: { "a" => "b" })).to be_a(Google::Protobuf::Struct)
      end
    end

    context "get value with evaluated context" do
      it do
        expect(
          client.fetch_boolean_value(
            flag_key: 'boolean-flag-targeting',
            default_value: false,
            evaluation_context: OpenFeature::SDK::EvaluationContext.new(be_true: true)
          )
        ).to be_truthy
      end

      it do
        fetch_value_with_targeting_key = ->(targeting_key) do
          client.fetch_boolean_value(
            flag_key: 'color-palette-experiment',
            default_value: "#b91c1c",
            evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: targeting_key)
          )
        end

        initial_value = fetch_value_with_targeting_key.("123")
        (0..2).to_a.each do # try with 1000
          expect(fetch_value_with_targeting_key.("123")).to eq(initial_value)
        end
      end
    end

    context "get details" do
      it do
        expect(client.fetch_boolean_details(flag_key: 'boolean-flag', default_value: false).resolution_details.to_h).to include(
          error_code: nil,
          error_message: nil,
          reason: "STATIC",
          value: false,
          variant: "off",
        )
      end

      it do
        expect(client.fetch_number_details(flag_key: "integer-flag", default_value: 1).resolution_details.to_h).to include(
          error_code: nil,
          error_message: nil,
          reason: "STATIC",
          value: 42,
          variant: "fourty-two",
        )
      end

      it do
        expect(client.fetch_number_details(flag_key: "float-flag", default_value: 1.1).resolution_details.to_h).to include(
          error_code: nil,
          error_message: nil,
          reason: "STATIC",
          value: 4.2,
          variant: "four-point-two",
        )
      end

      it do
        expect(client.fetch_string_details(flag_key: "string-flag", default_value: "lololo").resolution_details.to_h).to include(
          error_code: nil,
          error_message: nil,
          reason: "STATIC",
          value: "lalala",
          variant: "lilili",
        )
      end

      it do
        expect(client.fetch_object_details(flag_key: "object-flag", default_value: { "a" => "b" }).resolution_details.to_h).to include(
          error_code: nil,
          error_message: nil,
          reason: "STATIC",
          variant: "real-object",
        )
      end
    end
  end
end
