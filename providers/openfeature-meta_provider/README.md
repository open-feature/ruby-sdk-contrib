# OpenFeature Meta Provider for Ruby

The `OpenFeature::MetaProvider` is a utility provider that wraps multiple [providers](https://docs.openfeature.dev/docs/specification/sections/providers) and uses a configurable strategy to resolve flags across all of them. This is useful when an organization is migrating or consolidating feature flag providers as they transition to OpenFeature. If your organization has different providers for different teams, consider using [domains](https://openfeature.dev/specification/glossary#domain) instead.

## Features

| Status | Feature | Description |
|--------|---------|-------------|
| ✅ | Multi-Provider | Combine multiple providers into one |
| ✅ | Boolean Flags | Evaluate boolean feature flags |
| ✅ | String Flags | Evaluate string feature flags |
| ✅ | Number Flags | Evaluate numeric feature flags |
| ✅ | Object Flags | Evaluate object feature flags |
| ✅ | First Match Strategy | Return the first successful resolution across providers |
| ✅ | Provider Metadata | Tracks which provider matched via `flag_metadata` |
| ✅ | Lifecycle Management | Delegates `init` and `shutdown` to all wrapped providers |

## Requirements

- Ruby >= 3.4

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'openfeature-meta_provider'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install openfeature-meta_provider
```

## Usage

### Basic Setup

```ruby
require "open_feature/sdk"
require "openfeature/meta_provider"

# Create individual providers
provider_a = SomeProviderA.new
provider_b = SomeProviderB.new

# Create a MetaProvider that wraps them
meta_provider = OpenFeature::MetaProvider.new(
  providers: [provider_a, provider_b],
  strategy: :first_match
)

# Set the provider in OpenFeature
OpenFeature::SDK.configure do |config|
  config.set_provider(meta_provider)
end

# Get a client
client = OpenFeature::SDK.build_client
```

### Evaluating Flags

```ruby
# The MetaProvider delegates to its wrapped providers
enabled = client.fetch_boolean_value(
  flag_key: "new_feature",
  default_value: false
)

# With evaluation context
evaluation_context = OpenFeature::SDK::EvaluationContext.new(
  targeting_key: "user_123"
)

theme = client.fetch_string_value(
  flag_key: "theme",
  default_value: "light",
  evaluation_context: evaluation_context
)
```

### Identifying Which Provider Matched

When a flag is resolved, the `flag_metadata` includes a `matched_provider` field indicating which provider returned the result:

```ruby
details = client.fetch_boolean_details(
  flag_key: "new_feature",
  default_value: false
)

puts details.flag_metadata["matched_provider"]  # => "SomeProviderA"
```

## Configuration Options

The provider constructor accepts the following parameters:

| Option | Type | Default | Required | Description |
|--------|------|---------|----------|-------------|
| `providers` | Array | - | **Yes** | An ordered array of provider instances to delegate to |
| `strategy` | Symbol | `:first_match` | No | The resolution strategy to use |

## Strategies

### `:first_match`

When `:first_match` is given as the strategy, each provider is evaluated in the order it was passed in for the requested `flag_key`. The first provider that returns a successful resolution (no error code) is used, short-circuiting evaluation with the remaining providers.

- If a provider raises an exception, it is skipped and the next provider is tried.
- If a provider returns a resolution with an error code, it is skipped and the next provider is tried.
- If no provider returns a successful resolution, the default value is returned with an `ERROR` reason and a `GENERAL` error code.

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
gem build openfeature-meta_provider.gemspec
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

- [OpenFeature Documentation](https://openfeature.dev/)
- [OpenFeature Ruby SDK](https://github.com/open-feature/ruby-sdk)
- [Ruby SDK Contrib Repository](https://github.com/open-feature/ruby-sdk-contrib)

## Support

For issues related to:
- **This provider**: [GitHub Issues](https://github.com/open-feature/ruby-sdk-contrib/issues)
- **OpenFeature**: [OpenFeature Community](https://openfeature.dev/community/)
