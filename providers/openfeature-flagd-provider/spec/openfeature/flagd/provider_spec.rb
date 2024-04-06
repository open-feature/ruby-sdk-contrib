# frozen_string_literal: true

require "spec_helper"

# https://openfeature.dev/docs/specification/sections/providers

RSpec.describe OpenFeature::FlagD::Provider do
  context "#configure" do
    before do
      ENV["FLAGD_HOST"] = nil
      ENV["FLAGD_PORT"] = nil
      ENV["FLAGD_TLS"] = nil

      OpenFeature::FlagD::Provider.instance_variable_set(:@configuration, nil)
      OpenFeature::FlagD::Provider.instance_variable_set(:@explicit_configuration, nil)
    end

    context "when defining host, port and tls options of gRPC service it wishes to access with configure method" do
      subject(:explicit_configuration) do
        described_class.configure do |config|
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
        expect(described_class.configuration.host).to eq(explicit_host)
        expect(described_class.configuration.port).to eq(explicit_port)
        expect(described_class.configuration.tls).to eq(explicit_tls)
      end

      context "when defining environment variables" do
        before do
          ENV["FLAGD_HOST"] = "172.16.1.2"
          ENV["FLAGD_PORT"] = "8014"
          ENV["FLAGD_TLS"] = "true"
        end

        it "uses the explicit configuration" do
          explicit_configuration
          expect(described_class.configuration.host).to eq(explicit_host)
          expect(described_class.configuration.port).to eq(explicit_port)
          expect(described_class.configuration.tls).to eq(explicit_tls)
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
        described_class.configuration
      end

      it "uses environment variables when no explicit configuration" do
        env_configuration
        expect(env_configuration.host).to eq(env_host)
        expect(env_configuration.port).to eq(env_port)
        expect(env_configuration.tls).to eq(env_tls == "true")
      end
    end
  end

  # https://openfeature.dev/docs/specification/sections/providers#requirement-211
  context "#metadata" do
    it "metadata name is defined" do
      expect(described_class).to respond_to(:metadata)
      expect(described_class.metadata).to respond_to(:name)
      expect(described_class.metadata.name).to eq("flagd Provider")
    end
  end
end
