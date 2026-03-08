# frozen_string_literal: true

require "opentelemetry"
require "open_feature/sdk"

module OpenFeature
  module OTel
    module Hook
      class MetricsHook
        def initialize(meter_provider: ::OpenTelemetry.meter_provider)
          meter = meter_provider.meter("openfeature-otel-hook")

          @active_count = meter.create_up_down_counter(
            "feature_flag.evaluation_active_count",
            description: "Number of feature flag evaluations currently in progress"
          )
          @request_counter = meter.create_counter(
            "feature_flag.evaluation_requests_total",
            description: "Total number of feature flag evaluation requests"
          )
          @success_counter = meter.create_counter(
            "feature_flag.evaluation_success_total",
            description: "Total number of successful feature flag evaluations"
          )
          @error_counter = meter.create_counter(
            "feature_flag.evaluation_error_total",
            description: "Total number of errored feature flag evaluations"
          )
        end

        def before(hook_context:, hints:)
          attrs = base_attributes(hook_context)
          @active_count.add(1, attributes: attrs)
          @request_counter.add(1, attributes: attrs)
          nil
        rescue # rubocop:disable Lint/SuppressedException
        end

        def after(hook_context:, evaluation_details:, hints:)
          attrs = evaluation_attributes(hook_context, evaluation_details)
          @success_counter.add(1, attributes: attrs)
        rescue # rubocop:disable Lint/SuppressedException
        end

        def error(hook_context:, exception:, hints:)
          attrs = base_attributes(hook_context).merge(
            "error.type" => exception.class.name.downcase
          )
          @error_counter.add(1, attributes: attrs)
        rescue # rubocop:disable Lint/SuppressedException
        end

        def finally(hook_context:, evaluation_details:, hints:)
          attrs = base_attributes(hook_context)
          @active_count.add(-1, attributes: attrs)
        rescue # rubocop:disable Lint/SuppressedException
        end

        private

        def base_attributes(hook_context)
          attrs = {"feature_flag.key" => hook_context.flag_key}
          provider_name = hook_context.provider_metadata&.name
          attrs["feature_flag.provider.name"] = provider_name if provider_name
          attrs
        end

        def evaluation_attributes(hook_context, evaluation_details)
          event = ::OpenFeature::SDK::Telemetry.create_evaluation_event(
            hook_context: hook_context,
            evaluation_details: evaluation_details
          )
          event.attributes.transform_keys do |key|
            (key == "error.message") ? "feature_flag.error.message" : key
          end
        end
      end
    end
  end
end
