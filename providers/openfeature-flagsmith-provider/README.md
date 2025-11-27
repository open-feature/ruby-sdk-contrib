# OpenFeature Flagsmith Provider for Ruby

This is the Ruby provider for [Flagsmith](https://www.flagsmith.com/) feature flags, implementing the [OpenFeature](https://openfeature.dev/) standard.

## Features

| Status | Feature | Description |
|--------|---------|-------------|
| ✅ | Flag Evaluation | Support for all OpenFeature flag types |
| ✅ | Boolean Flags | Evaluate boolean feature flags |
| ✅ | String Flags | Evaluate string feature flags |
| ✅ | Number Flags | Evaluate numeric feature flags (int, float) |
| ✅ | Object Flags | Evaluate JSON object/array flags |
| ✅ | Evaluation Context | Support for user identity and traits |
| ✅ | Environment Flags | Evaluate flags at environment level |
| ✅ | Identity Flags | Evaluate flags for specific users |
| ✅ | Remote Evaluation | Default remote evaluation mode |
| ✅ | Local Evaluation | Optional local evaluation mode |
| ✅ | Error Handling | Comprehensive error handling |
| ✅ | Type Validation | Strict type checking |

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'openfeature-flagsmith-provider'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install openfeature-flagsmith-provider
```

## Usage

### Basic Setup

```ruby
require 'open_feature/sdk'
require 'openfeature/flagsmith/provider'
require 'openfeature/flagsmith/options'

# Configure the Flagsmith provider
options = OpenFeature::Flagsmith::Options.new(
  environment_key: 'your_flagsmith_environment_key'
)

provider = OpenFeature::Flagsmith::Provider.new(options: options)

# Set the provider in OpenFeature
OpenFeature::SDK.configure do |config|
  config.provider = provider
end

# Get a client
client = OpenFeature::SDK.build_client
```

### Evaluating Flags

#### Boolean Flags

```ruby
# Simple boolean flag
enabled = client.fetch_boolean_value(
  flag_key: 'new_feature',
  default_value: false
)

# With user context
evaluation_context = OpenFeature::SDK::EvaluationContext.new(
  targeting_key: 'user_123',
  email: 'user@example.com',
  age: 30
)

enabled = client.fetch_boolean_value(
  flag_key: 'new_feature',
  default_value: false,
  evaluation_context: evaluation_context
)
```

#### String Flags

```ruby
theme = client.fetch_string_value(
  flag_key: 'theme',
  default_value: 'light',
  evaluation_context: evaluation_context
)
```

#### Number Flags

```ruby
max_items = client.fetch_integer_value(
  flag_key: 'max_items',
  default_value: 10,
  evaluation_context: evaluation_context
)

rate_limit = client.fetch_float_value(
  flag_key: 'rate_limit',
  default_value: 1.5,
  evaluation_context: evaluation_context
)
```

#### Object Flags

```ruby
config = client.fetch_object_value(
  flag_key: 'app_config',
  default_value: {timeout: 30},
  evaluation_context: evaluation_context
)
```

## Configuration Options

The `Options` class accepts the following configuration parameters:

| Option | Type | Default | Required | Description |
|--------|------|---------|----------|-------------|
| `environment_key` | String | - | **Yes** | Your Flagsmith environment key |
| `api_url` | String | `https://edge.api.flagsmith.com/api/v1/` | No | Custom Flagsmith API URL (for self-hosting) |
| `enable_local_evaluation` | Boolean | `false` | No | Enable local evaluation mode |
| `request_timeout_seconds` | Integer | `10` | No | HTTP request timeout in seconds |
| `enable_analytics` | Boolean | `false` | No | Enable Flagsmith analytics |
| `environment_refresh_interval_seconds` | Integer | `60` | No | Polling interval for local evaluation mode |

### Configuration Examples

#### Default Configuration

```ruby
options = OpenFeature::Flagsmith::Options.new(
  environment_key: 'your_key'
)
```

#### Custom API URL (Self-Hosted)

```ruby
options = OpenFeature::Flagsmith::Options.new(
  environment_key: 'your_key',
  api_url: 'https://flagsmith.yourcompany.com/api/v1/'
)
```

#### Local Evaluation Mode

```ruby
options = OpenFeature::Flagsmith::Options.new(
  environment_key: 'your_key',
  enable_local_evaluation: true,
  environment_refresh_interval_seconds: 30
)
```

#### With Analytics

```ruby
options = OpenFeature::Flagsmith::Options.new(
  environment_key: 'your_key',
  enable_analytics: true
)
```

## Evaluation Context

The provider supports OpenFeature evaluation contexts to pass user information and traits to Flagsmith:

### Targeting Key → Identity

The `targeting_key` maps to Flagsmith's identity identifier. **Note:** Flagsmith requires an identity to evaluate traits, so if you provide traits without a `targeting_key`, they will be ignored and evaluation falls back to environment-level flags.

```ruby
evaluation_context = OpenFeature::SDK::EvaluationContext.new(
  targeting_key: 'user@example.com'
)
```

### Context Fields → Traits

All other context fields are passed as Flagsmith traits:

```ruby
evaluation_context = OpenFeature::SDK::EvaluationContext.new(
  targeting_key: 'user_123',
  email: 'user@example.com',
  plan: 'premium',
  age: 30
)
```

This will evaluate flags for identity `user_123` with traits:
- `email`: "user@example.com"
- `plan`: "premium"
- `age`: 30

### Environment-Level vs Identity-Specific

**Without `targeting_key` (Environment-level):**
```ruby
# Evaluates flags at environment level
client.fetch_boolean_value(
  flag_key: 'feature',
  default_value: false
)
```

**With `targeting_key` (Identity-specific):**
```ruby
# Evaluates flags for specific user identity
evaluation_context = OpenFeature::SDK::EvaluationContext.new(
  targeting_key: 'user_123'
)

client.fetch_boolean_value(
  flag_key: 'feature',
  default_value: false,
  evaluation_context: evaluation_context
)
```

## Error Handling

The provider handles errors gracefully and returns the default value with appropriate error codes:

```ruby
result = client.fetch_boolean_details(
  flag_key: 'unknown_flag',
  default_value: false
)

puts result.value          # => false (default value)
puts result.error_code     # => FLAG_NOT_FOUND
puts result.error_message  # => "Flag 'unknown_flag' not found"
puts result.reason         # => DEFAULT
```

### Error Codes

| Error Code | Description |
|------------|-------------|
| `FLAG_NOT_FOUND` | The requested flag does not exist |
| `TYPE_MISMATCH` | The flag value type doesn't match the requested type |
| `PROVIDER_NOT_READY` | The Flagsmith client is not properly initialized |
| `PARSE_ERROR` | Failed to parse the flag value |
| `INVALID_CONTEXT` | The evaluation context is invalid |
| `GENERAL` | A general error occurred |

## Reasons

The provider returns appropriate reasons for flag evaluations:

| Reason | Description |
|--------|-------------|
| `TARGETING_MATCH` | Flag evaluated with user identity (targeting_key provided) |
| `STATIC` | Flag evaluated at environment level (no targeting_key) |
| `DEFAULT` | Default value returned due to flag not found |
| `ERROR` | An error occurred during evaluation |
| `DISABLED` | The flag was disabled, and the default value was returned |

**Note**: Both remote and local evaluation modes use the same reason mapping (STATIC/TARGETING_MATCH). Local evaluation performs flag evaluation locally but still evaluates the flag state, it doesn't return cached results.

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
gem build openfeature-flagsmith-provider.gemspec
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

- [Flagsmith Documentation](https://docs.flagsmith.com/)
- [OpenFeature Documentation](https://openfeature.dev/)
- [OpenFeature Ruby SDK](https://github.com/open-feature/ruby-sdk)
- [Ruby SDK Contrib Repository](https://github.com/open-feature/ruby-sdk-contrib)

## Support

For issues related to:
- **This provider**: [GitHub Issues](https://github.com/open-feature/ruby-sdk-contrib/issues)
- **Flagsmith**: [Flagsmith Support](https://www.flagsmith.com/contact-us)
- **OpenFeature**: [OpenFeature Community](https://openfeature.dev/community/)
