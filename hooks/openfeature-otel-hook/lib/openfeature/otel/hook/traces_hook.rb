# frozen_string_literal: true

require "opentelemetry"
require "open_feature/sdk"

module OpenFeature
  module OTel
    module Hook
      class TracesHook
        def finally(hook_context:, evaluation_details:, hints:)
          span = ::OpenTelemetry::Trace.current_span
          return unless span.recording?

          event = ::OpenFeature::SDK::Telemetry.create_evaluation_event(
            hook_context: hook_context,
            evaluation_details: evaluation_details
          )

          span.add_event(event.name, attributes: remap_attributes(event.attributes))
        rescue # rubocop:disable Lint/SuppressedException
        end

        private

        def remap_attributes(attributes)
          attributes.transform_keys do |key|
            (key == "error.message") ? "feature_flag.error.message" : key
          end
        end
      end
    end
  end
end
