# OpenFeature OFREP Provider for Ruby

An [OpenFeature](https://openfeature.dev/) provider for [OFREP](https://openfeature.dev/docs/reference/technologies/remote-evaluation-protocol) (OpenFeature Remote Evaluation Protocol) compliant feature flag servers.

OFREP is a vendor-neutral protocol that allows any compliant server to be used with this provider, including [flagd](https://flagd.dev/), [GO Feature Flag](https://gofeatureflag.org/), and others.

## Features

| Status | Feature | Description |
|--------|---------|-------------|
| ✅ | Flag Evaluation | Support for all OpenFeature flag types |
| ✅ | Boolean Flags | Evaluate boolean feature flags |
| ✅ | String Flags | Evaluate string feature flags |
| ✅ | Number Flags | Evaluate numeric feature flags (integer, float) |
| ✅ | Object Flags | Evaluate JSON object/array flags |
| ✅ | Evaluation Context | Support for targeting key and custom attributes |
| ✅ | Custom Headers | Configurable HTTP headers for authentication |
| ✅ | Error Handling | Comprehensive error handling with typed errors |
| ✅ | Type Validation | Strict type checking for flag values |

## Requirements

- Ruby >= 3.4

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

### Basic Setup

```ruby
require "open_feature/sdk"
require "openfeature/ofrep/provider"

# Configure the OFREP provider
configuration = OpenFeature::OFREP::Configuration.new(
  base_url: "http://localhost:8080",
  headers: { "Authorization" => "Bearer my-token" },
  timeout: 10
)

provider = OpenFeature::OFREP::Provider.new(configuration: configuration)

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
evaluation_context = OpenFeature::SDK::EvaluationContext.new(
  targeting_key: "user_123"
)

enabled = client.fetch_boolean_value(
  flag_key: "new_feature",
  default_value: false,
  evaluation_context: evaluation_context
)
```

#### String Flags

```ruby
theme = client.fetch_string_value(
  flag_key: "theme",
  default_value: "light",
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

The `Configuration` class accepts the following parameters:

| Option | Type | Default | Required | Description |
|--------|------|---------|----------|-------------|
| `base_url` | String | - | **Yes** | Base URL of the OFREP-compliant server (must be a valid HTTP/HTTPS URL) |
| `headers` | Hash | `{}` | No | Custom HTTP headers (e.g., for authentication) |
| `timeout` | Integer | `10` | No | HTTP request timeout in seconds |

### Configuration Examples

#### Minimal Configuration

```ruby
configuration = OpenFeature::OFREP::Configuration.new(
  base_url: "http://localhost:8080"
)
```

#### With Authentication

```ruby
configuration = OpenFeature::OFREP::Configuration.new(
  base_url: "https://flags.example.com",
  headers: { "Authorization" => "Bearer your-api-key" }
)
```

#### Custom Timeout

```ruby
configuration = OpenFeature::OFREP::Configuration.new(
  base_url: "https://flags.example.com",
  headers: { "Authorization" => "Bearer your-api-key" },
  timeout: 30
)
```

## Evaluation Context

The OFREP provider requires a `targeting_key` in the evaluation context. If the `targeting_key` is missing or empty, an `INVALID_CONTEXT` error is returned.

```ruby
evaluation_context = OpenFeature::SDK::EvaluationContext.new(
  targeting_key: "user_123",
  email: "user@example.com",
  plan: "premium"
)
```

## Error Handling

The provider handles errors gracefully and returns the default value with appropriate error codes:

```ruby
details = client.fetch_boolean_details(
  flag_key: "unknown_flag",
  default_value: false,
  evaluation_context: evaluation_context
)

puts details.value          # => false (default value)
puts details.error_code     # => FLAG_NOT_FOUND
puts details.error_message  # => "Flag not found: unknown_flag"
puts details.reason         # => ERROR
```

### Error Codes

| Error Code | Description |
|------------|-------------|
| `FLAG_NOT_FOUND` | The requested flag does not exist on the server |
| `TYPE_MISMATCH` | The flag value type does not match the requested type |
| `PARSE_ERROR` | Failed to parse the server response |
| `INVALID_CONTEXT` | The evaluation context is invalid (e.g., missing `targeting_key`) |
| `GENERAL` | A general error occurred (unauthorized, internal server error, invalid flag key, or rate limited) |

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
gem build openfeature-ofrep-provider.gemspec
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

- [OFREP Specification](https://openfeature.dev/docs/reference/technologies/remote-evaluation-protocol)
- [OpenFeature Documentation](https://openfeature.dev/)
- [OpenFeature Ruby SDK](https://github.com/open-feature/ruby-sdk)
- [Ruby SDK Contrib Repository](https://github.com/open-feature/ruby-sdk-contrib)

## Support

For issues related to:
- **This provider**: [GitHub Issues](https://github.com/open-feature/ruby-sdk-contrib/issues)
- **OpenFeature**: [OpenFeature Community](https://openfeature.dev/community/)
