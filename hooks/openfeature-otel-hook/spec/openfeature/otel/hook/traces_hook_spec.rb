# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenFeature::OTel::Hook::TracesHook do
  let(:hook) { described_class.new }

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

  let(:exporter) { OpenTelemetry::SDK::Trace::Export::InMemorySpanExporter.new }
  let(:span_processor) { OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new(exporter) }

  around do |example|
    OpenTelemetry::SDK.configure do |c|
      c.add_span_processor(span_processor)
    end
    example.run
    OpenTelemetry.tracer_provider.shutdown
  end

  describe "#finally" do
    context "with a successful evaluation" do
      it "adds a span event with correct name and attributes" do
        details = build_details(value: true, variant: "on", reason: "TARGETING_MATCH",
          flag_metadata: {"contextId" => "ctx-1", "flagSetId" => "set-1", "version" => "v1"})

        tracer = OpenTelemetry.tracer_provider.tracer("test")
        tracer.in_span("test-span") do
          hook.finally(hook_context: hook_context, evaluation_details: details, hints: {})
        end

        spans = exporter.finished_spans
        expect(spans.length).to eq(1)
        events = spans.first.events
        expect(events.length).to eq(1)
        expect(events.first.name).to eq("feature_flag.evaluation")
        expect(events.first.attributes["feature_flag.key"]).to eq("my-flag")
        expect(events.first.attributes["feature_flag.provider.name"]).to eq("test-provider")
        expect(events.first.attributes["feature_flag.result.variant"]).to eq("on")
        expect(events.first.attributes["feature_flag.result.reason"]).to eq("targeting_match")
        expect(events.first.attributes["feature_flag.context.id"]).to eq("ctx-1")
        expect(events.first.attributes["feature_flag.set.id"]).to eq("set-1")
        expect(events.first.attributes["feature_flag.version"]).to eq("v1")
      end

      it "uses value when variant is absent" do
        details = build_details(value: "blue", reason: "STATIC")

        tracer = OpenTelemetry.tracer_provider.tracer("test")
        tracer.in_span("test-span") do
          hook.finally(hook_context: hook_context, evaluation_details: details, hints: {})
        end

        events = exporter.finished_spans.first.events
        expect(events.first.attributes["feature_flag.result.value"]).to eq("blue")
        expect(events.first.attributes).not_to have_key("feature_flag.result.variant")
      end
    end

    context "with an error evaluation" do
      it "remaps error.message to feature_flag.error.message" do
        details = build_details(
          value: false, reason: "ERROR",
          error_code: "FLAG_NOT_FOUND", error_message: "Flag not found"
        )

        tracer = OpenTelemetry.tracer_provider.tracer("test")
        tracer.in_span("test-span") do
          hook.finally(hook_context: hook_context, evaluation_details: details, hints: {})
        end

        attrs = exporter.finished_spans.first.events.first.attributes
        expect(attrs["error.type"]).to eq("flag_not_found")
        expect(attrs["feature_flag.error.message"]).to eq("Flag not found")
        expect(attrs).not_to have_key("error.message")
      end
    end

    context "when no span is active" do
      it "does not raise" do
        details = build_details(value: true, variant: "on")

        expect {
          hook.finally(hook_context: hook_context, evaluation_details: details, hints: {})
        }.not_to raise_error
      end
    end

    context "error resilience" do
      it "swallows exceptions and does not propagate" do
        bad_context = double("hook_context", flag_key: nil, provider_metadata: nil, evaluation_context: nil)
        allow(OpenFeature::SDK::Telemetry).to receive(:create_evaluation_event).and_raise(StandardError, "boom")

        tracer = OpenTelemetry.tracer_provider.tracer("test")
        tracer.in_span("test-span") do
          expect {
            hook.finally(hook_context: bad_context, evaluation_details: nil, hints: {})
          }.not_to raise_error
        end
      end
    end
  end
end
