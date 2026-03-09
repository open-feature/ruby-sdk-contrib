# OpenFeature OFREP Provider for Ruby

An [OpenFeature](https://openfeature.dev) provider for [OFREP](https://openfeature.dev/docs/reference/technologies/remote-evaluation-protocol) (OpenFeature Remote Evaluation Protocol) compliant feature flag servers.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'openfeature-ofrep-provider'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install openfeature-ofrep-provider
```

## Usage

```ruby
require "openfeature/ofrep/provider"

configuration = OpenFeature::OFREP::Configuration.new(
  base_url: "http://localhost:8080",
  headers: {"Authorization" => "Bearer my-token"},
  timeout: 10
)

provider = OpenFeature::OFREP::Provider.new(configuration: configuration)

OpenFeature::SDK.configure do |config|
  config.set_provider(provider)
end

client = OpenFeature::SDK.build_client

result = client.fetch_boolean_value(
  flag_key: "my-flag",
  default_value: false,
  evaluation_context: OpenFeature::SDK::EvaluationContext.new(targeting_key: "user-123")
)
```

## Configuration

| Option     | Type    | Default | Description                                      |
|------------|---------|---------|--------------------------------------------------|
| `base_url` | String  | *required* | Base URL of the OFREP-compliant server        |
| `headers`  | Hash    | `{}`    | Custom headers (e.g., for authentication)        |
| `timeout`  | Integer | `10`    | HTTP timeout in seconds                          |

## Version 0.1.0
