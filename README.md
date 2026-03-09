# OpenFeature Ruby SDK Contributions

[![CI](https://github.com/open-feature/ruby-sdk-contrib/actions/workflows/ruby.yml/badge.svg)](https://github.com/open-feature/ruby-sdk-contrib/actions/workflows/ruby.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.4-red.svg)](https://www.ruby-lang.org/)

Community-contributed [providers](https://openfeature.dev/docs/reference/concepts/provider) and [hooks](https://openfeature.dev/docs/reference/concepts/hooks) for the [OpenFeature Ruby SDK](https://github.com/open-feature/ruby-sdk).

## Providers

| Provider | Version | Description |
|----------|---------|-------------|
| [flagd](./providers/openfeature-flagd-provider) | 0.1.4 | gRPC-based [flagd](https://flagd.dev/) provider |
| [Flagsmith](./providers/openfeature-flagsmith-provider) | 0.1.1 | [Flagsmith](https://flagsmith.com/) provider |
| [Flipt](./providers/openfeature-flipt-provider) | 0.0.2 | [Flipt](https://www.flipt.io/) provider |
| [GO Feature Flag](./providers/openfeature-go-feature-flag-provider) | 0.1.10 | [GO Feature Flag](https://gofeatureflag.org/) provider |
| [Meta Provider](./providers/openfeature-meta_provider) | 0.0.5 | Combines multiple providers with strategy-based evaluation |
| [OFREP](./providers/openfeature-ofrep-provider) | 0.1.0 | [OFREP](https://openfeature.dev/specification/appendix-c-ofrep/) (OpenFeature Remote Evaluation Protocol) provider |

## Hooks

| Hook | Version | Description |
|------|---------|-------------|
| [OpenTelemetry](./hooks/openfeature-otel-hook) | 0.1.0 | Traces and metrics via [OpenTelemetry](https://opentelemetry.io/) |

## Supported Ruby Versions

Ruby >= 3.4 (tested on 3.4 and 4.0)

## Quick Start

Add the desired provider gem to your `Gemfile`:

```ruby
gem "openfeature-flagd-provider"
```

Then configure the OpenFeature SDK:

```ruby
require "openfeature/sdk"
require "openfeature/flagd/provider"

OpenFeature::SDK.configure do |config|
  config.set_provider(OpenFeature::Flagd::Provider.new)
end

client = OpenFeature::SDK.build_client
value = client.fetch_boolean_value(flag_key: "my-flag", default_value: false)
```

See each provider's README for detailed configuration options.

## Releases

This repo uses [Release Please](https://github.com/googleapis/release-please) to release packages. Release Please sets up a running PR that tracks all changes for the library components, and maintains the versions according to [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/), generated when [PRs are merged](https://github.com/amannn/action-semantic-pull-request). When Release Please's running PR is merged, any changed artifacts are published.

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to this project.

## License

Apache 2.0 - See [LICENSE](./LICENSE) for more information.
