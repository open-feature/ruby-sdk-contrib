# OpenFeature Flipt Provider for Ruby

This is the Ruby provider for [Flipt](https://www.flipt.io/), a feature flagging and experimentation platform, implementing the [OpenFeature](https://openfeature.dev/) standard.

In conjunction with the [OpenFeature SDK](https://openfeature.dev/docs/reference/concepts/provider/) you can use this provider to integrate Flipt into your Ruby application.

## Features

| Status | Feature | Description |
|--------|---------|-------------|
| ✅ | Flag Evaluation | Support for all OpenFeature flag types |
| ✅ | Boolean Flags | Evaluate boolean feature flags |
| ✅ | String Flags | Evaluate string feature flags |
| ✅ | Number Flags | Evaluate numeric feature flags (integer, float) |
| ✅ | Object Flags | Evaluate JSON object flags |
| ✅ | Evaluation Context | Support for entity ID and context attributes |
| ✅ | Namespace Support | Evaluate flags within a specific namespace |
| ✅ | Error Handling | Comprehensive error handling with default values |

## Requirements

- Ruby >= 3.4

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'openfeature-flipt-provider'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install openfeature-flipt-provider
```

## Usage

### Basic Setup

```ruby
require "open_feature/sdk"
require "openfeature/flipt/provider"

# Configure the Flipt provider
provider = OpenFeature::Flipt::Provider.new(
  namespace: "my-namespace",
  options: {
    url: "http://localhost:8080",
    authentication: "your-api-token"
  }
)

# Set the provider in OpenFeature
OpenFeature::SDK.configure do |config|
  config.set_provider(provider)
end

# Get a client
client = OpenFeature::SDK.build_client
```

### Evaluating Flags

#### Boolean Flags

```ruby
# Simple boolean flag
enabled = client.fetch_boolean_value(
  flag_key: "new_feature",
  default_value: false
)

# With evaluation context
evaluation_context = OpenFeature::SDK::EvaluationContext.new(
  targeting_key: "user_123",
  email: "user@example.com",
  plan: "premium"
)

enabled = client.fetch_boolean_value(
  flag_key: "new_feature",
  default_value: false,
  evaluation_context: evaluation_context
)
```

#### String Flags

```ruby
variant = client.fetch_string_value(
  flag_key: "color_scheme",
  default_value: "default",
  evaluation_context: evaluation_context
)
```

#### Number Flags

```ruby
max_items = client.fetch_integer_value(
  flag_key: "max_items",
  default_value: 10,
  evaluation_context: evaluation_context
)

rate_limit = client.fetch_float_value(
  flag_key: "rate_limit",
  default_value: 1.5,
  evaluation_context: evaluation_context
)
```

#### Object Flags

```ruby
config = client.fetch_object_value(
  flag_key: "app_config",
  default_value: { "timeout" => 30 },
  evaluation_context: evaluation_context
)
```

## Configuration Options

The provider constructor accepts the following parameters:

| Option | Type | Default | Required | Description |
|--------|------|---------|----------|-------------|
| `namespace` | String | `"default"` | No | The Flipt namespace to use when fetching flags |
| `options` | Hash | `{}` | No | Options passed to the underlying Flipt client (see below) |

The `options` hash is passed directly to the [Flipt Client Ruby SDK](https://github.com/flipt-io/flipt-client-sdks/tree/main/flipt-client-ruby). Common options include:

| Option | Type | Description |
|--------|------|-------------|
| `url` | String | URL of the Flipt server |
| `update_interval` | Integer | Polling interval in seconds for fetching flag state |
| `authentication` | String | Authentication token for the Flipt server |

For a complete list of client options, refer to the [Flipt Client Ruby SDK documentation](https://github.com/flipt-io/flipt-client-sdks/tree/main/flipt-client-ruby#constructor-arguments).

## Evaluation Context

The provider maps OpenFeature evaluation context fields to Flipt evaluation parameters:

- `targeting_key` maps to the Flipt `entity_id`. If not provided, defaults to `"default"`.
- All other context fields are passed as string key-value pairs in the Flipt evaluation context.

```ruby
evaluation_context = OpenFeature::SDK::EvaluationContext.new(
  targeting_key: "user_123",
  plan: "premium",
  region: "us-east-1"
)
```

## Error Handling

The provider handles errors gracefully and returns the default value with appropriate reasons:

| Reason | Description |
|--------|-------------|
| `TARGETING_MATCH` | Flag evaluated successfully (default or match reason from Flipt) |
| `DISABLED` | The flag is disabled in Flipt |
| `UNKNOWN` | Flipt returned an unknown evaluation reason |
| `DEFAULT` | Default value returned (unrecognized Flipt reason) |
| `ERROR` | An error occurred during evaluation |

## Development

### Running Tests

```bash
bundle install
bundle exec rspec
```

### Running Linter

```bash
bundle exec rubocop
```

### Building the Gem

```bash
gem build openfeature-flipt-provider.gemspec
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

Apache 2.0 - See [LICENSE](LICENSE) for more information.

## Links

- [Flipt Documentation](https://docs.flipt.io/)
- [Flipt Client Ruby SDK](https://github.com/flipt-io/flipt-client-sdks/tree/main/flipt-client-ruby)
- [OpenFeature Documentation](https://openfeature.dev/)
- [OpenFeature Ruby SDK](https://github.com/open-feature/ruby-sdk)
- [Ruby SDK Contrib Repository](https://github.com/open-feature/ruby-sdk-contrib)

## Support

For issues related to:
- **This provider**: [GitHub Issues](https://github.com/open-feature/ruby-sdk-contrib/issues)
- **Flipt**: [Flipt Community](https://www.flipt.io/docs)
- **OpenFeature**: [OpenFeature Community](https://openfeature.dev/community/)
