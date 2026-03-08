# OpenFeature OTel Hook

OpenTelemetry hooks for the [OpenFeature Ruby SDK](https://github.com/open-feature/ruby-sdk). Provides `TracesHook` and `MetricsHook` for emitting OTel signals during feature flag evaluations.

Complies with:
- [OTel Semantic Conventions for Feature Flag Events](https://opentelemetry.io/docs/specs/semconv/feature-flags/feature-flags-events/)
- [OpenFeature Spec Appendix D (Observability)](https://openfeature.dev/specification/appendix-d/)

## Installation

```ruby
gem "openfeature-otel-hook", "~> 0.1.0"
```

## Usage

### TracesHook

Adds `feature_flag.evaluation` span events to the current active span.

```ruby
require "openfeature/otel/hook"

# Register globally
OpenFeature::SDK.configure do |config|
  config.hooks << OpenFeature::OTel::Hook::TracesHook.new
end
```

### MetricsHook

Tracks evaluation counters: requests, successes, errors, and active evaluations.

```ruby
require "openfeature/otel/hook"

# Register globally (uses global MeterProvider)
OpenFeature::SDK.configure do |config|
  config.hooks << OpenFeature::OTel::Hook::MetricsHook.new
end

# Or with a custom MeterProvider
metrics_hook = OpenFeature::OTel::Hook::MetricsHook.new(
  meter_provider: my_meter_provider
)
```

### Metrics Emitted

| Metric | Type | Description |
|--------|------|-------------|
| `feature_flag.evaluation_active_count` | UpDownCounter | Evaluations currently in progress |
| `feature_flag.evaluation_requests_total` | Counter | Total evaluation requests |
| `feature_flag.evaluation_success_total` | Counter | Total successful evaluations |
| `feature_flag.evaluation_error_total` | Counter | Total errored evaluations |

## Requirements

- Ruby >= 3.4
- `openfeature-sdk` ~> 0.6
- `opentelemetry-api` ~> 1.0
- Your application must configure an OpenTelemetry SDK with appropriate exporters

## License

Apache-2.0
