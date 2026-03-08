# frozen_string_literal: true

require "spec_helper"
require "opentelemetry-metrics-sdk"

RSpec.describe OpenFeature::OTel::Hook::MetricsHook do
  let(:metric_reader) { OpenTelemetry::SDK::Metrics::Export::InMemoryMetricPullExporter.new }
  let(:meter_provider) do
    OpenTelemetry::SDK::Metrics::MeterProvider.new.tap do |mp|
      mp.add_metric_reader(metric_reader)
    end
  end
  let(:hook) { described_class.new(meter_provider: meter_provider) }

  let(:evaluation_context) { OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123") }
  let(:provider_metadata) { OpenFeature::SDK::Provider::ProviderMetadata.new(name: "test-provider") }

  let(:hook_context) do
    OpenFeature::SDK::Hooks::HookContext.new(
      flag_key: "my-flag",
      flag_value_type: :boolean,
      default_value: false,
      evaluation_context: evaluation_context,
      provider_metadata: provider_metadata
    )
  end

  def build_details(flag_key: "my-flag", **resolution_attrs)
    resolution = OpenFeature::SDK::Provider::ResolutionDetails.new(**resolution_attrs)
    OpenFeature::SDK::EvaluationDetails.new(flag_key: flag_key, resolution_details: resolution)
  end

  def find_metric(name)
    metric_reader.pull
    metric_reader.metric_snapshots.find { |m| m.name == name }
  end

  def metric_value(name)
    metric = find_metric(name)
    return 0 unless metric&.data_points&.any?
    metric.data_points.sum(&:value)
  end

  describe "#before" do
    it "increments active_count and request_counter" do
      hook.before(hook_context: hook_context, hints: {})

      expect(metric_value("feature_flag.evaluation_active_count")).to eq(1)
      expect(metric_value("feature_flag.evaluation_requests_total")).to eq(1)
    end

    it "returns nil to avoid modifying evaluation context" do
      result = hook.before(hook_context: hook_context, hints: {})
      expect(result).to be_nil
    end
  end

  describe "#after" do
    it "increments success_counter" do
      details = build_details(value: true, variant: "on", reason: "TARGETING_MATCH")

      hook.after(hook_context: hook_context, evaluation_details: details, hints: {})

      expect(metric_value("feature_flag.evaluation_success_total")).to eq(1)
    end
  end

  describe "#error" do
    it "increments error_counter with error type" do
      exception = StandardError.new("something broke")

      hook.error(hook_context: hook_context, exception: exception, hints: {})

      expect(metric_value("feature_flag.evaluation_error_total")).to eq(1)
    end
  end

  describe "#finally" do
    it "decrements active_count" do
      hook.before(hook_context: hook_context, hints: {})
      hook.finally(hook_context: hook_context, evaluation_details: nil, hints: {})

      expect(metric_value("feature_flag.evaluation_active_count")).to eq(0)
    end
  end

  describe "full lifecycle" do
    it "tracks a complete successful evaluation" do
      details = build_details(value: true, variant: "on", reason: "STATIC")

      hook.before(hook_context: hook_context, hints: {})
      hook.after(hook_context: hook_context, evaluation_details: details, hints: {})
      hook.finally(hook_context: hook_context, evaluation_details: details, hints: {})

      expect(metric_value("feature_flag.evaluation_active_count")).to eq(0)
      expect(metric_value("feature_flag.evaluation_requests_total")).to eq(1)
      expect(metric_value("feature_flag.evaluation_success_total")).to eq(1)
      expect(metric_value("feature_flag.evaluation_error_total")).to eq(0)
    end

    it "tracks a complete errored evaluation" do
      exception = RuntimeError.new("provider down")

      hook.before(hook_context: hook_context, hints: {})
      hook.error(hook_context: hook_context, exception: exception, hints: {})
      hook.finally(hook_context: hook_context, evaluation_details: nil, hints: {})

      expect(metric_value("feature_flag.evaluation_active_count")).to eq(0)
      expect(metric_value("feature_flag.evaluation_requests_total")).to eq(1)
      expect(metric_value("feature_flag.evaluation_success_total")).to eq(0)
      expect(metric_value("feature_flag.evaluation_error_total")).to eq(1)
    end
  end

  describe "custom meter_provider" do
    it "accepts an injected meter_provider" do
      custom_reader = OpenTelemetry::SDK::Metrics::Export::InMemoryMetricPullExporter.new
      custom_provider = OpenTelemetry::SDK::Metrics::MeterProvider.new.tap do |mp|
        mp.add_metric_reader(custom_reader)
      end
      custom_hook = described_class.new(meter_provider: custom_provider)

      custom_hook.before(hook_context: hook_context, hints: {})

      custom_reader.pull
      metric = custom_reader.metric_snapshots.find { |m| m.name == "feature_flag.evaluation_requests_total" }
      expect(metric.data_points.sum(&:value)).to eq(1)
    end
  end

  describe "error resilience" do
    it "swallows exceptions in before" do
      allow(hook_context).to receive(:flag_key).and_raise(StandardError, "boom")
      expect { hook.before(hook_context: hook_context, hints: {}) }.not_to raise_error
    end

    it "swallows exceptions in after" do
      allow(OpenFeature::SDK::Telemetry).to receive(:create_evaluation_event).and_raise(StandardError)
      details = build_details(value: true, variant: "on")
      expect { hook.after(hook_context: hook_context, evaluation_details: details, hints: {}) }.not_to raise_error
    end

    it "swallows exceptions in error" do
      allow(hook_context).to receive(:flag_key).and_raise(StandardError, "boom")
      expect { hook.error(hook_context: hook_context, exception: RuntimeError.new, hints: {}) }.not_to raise_error
    end

    it "swallows exceptions in finally" do
      allow(hook_context).to receive(:flag_key).and_raise(StandardError, "boom")
      expect { hook.finally(hook_context: hook_context, evaluation_details: nil, hints: {}) }.not_to raise_error
    end
  end
end
