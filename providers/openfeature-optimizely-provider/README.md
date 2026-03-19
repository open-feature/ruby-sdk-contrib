# OpenFeature Optimizely Provider for Ruby

An [OpenFeature](https://openfeature.dev/) provider for [Optimizely](https://www.optimizely.com/) Feature Experimentation, built on the [Optimizely Ruby SDK](https://docs.developers.optimizely.com/feature-experimentation/docs/ruby-sdk).

## Installation

Add to your Gemfile:

```ruby
gem "openfeature-optimizely-provider"
```

## Usage

### Basic setup with SDK key

```ruby
require "openfeature/optimizely/provider"

configuration = OpenFeature::Optimizely::Configuration.new(sdk_key: "YOUR_SDK_KEY")
provider = OpenFeature::Optimizely::Provider.new(configuration: configuration)
provider.init

OpenFeature::SDK.configure do |config|
  config.set_provider(provider)
end

client = OpenFeature::SDK.build_client
```

### Using a pre-built Optimizely client

```ruby
optimizely_client = Optimizely::OptimizelyFactory.default_instance("YOUR_SDK_KEY")

configuration = OpenFeature::Optimizely::Configuration.new(optimizely_client: optimizely_client)
provider = OpenFeature::Optimizely::Provider.new(configuration: configuration)
provider.init
```

### Boolean evaluation

Boolean flags map directly to Optimizely's `decision.enabled`:

```ruby
context = OpenFeature::SDK::EvaluationContext.new(targeting_key: "user_123")
result = client.fetch_boolean_details(flag_key: "my_feature", default_value: false, evaluation_context: context)
result.value # => true/false
```

### Variable access with dotted notation

Optimizely flags can have typed variables. Access them using dotted notation (`flag_key.variable_key`):

```ruby
# String variable
result = client.fetch_string_details(flag_key: "checkout.button_text", default_value: "Buy", evaluation_context: context)
result.value # => "Add to Cart"

# Integer variable
result = client.fetch_integer_details(flag_key: "checkout.max_items", default_value: 10, evaluation_context: context)
result.value # => 25

# Float variable
result = client.fetch_float_details(flag_key: "pricing.discount_rate", default_value: 0.0, evaluation_context: context)
result.value # => 0.15

# Object variable
result = client.fetch_object_details(flag_key: "ui.theme_config", default_value: {}, evaluation_context: context)
result.value # => {"color" => "blue", "font_size" => 14}
```

### Variable key override via context

Instead of dotted notation, you can specify the variable key in the evaluation context:

```ruby
context = OpenFeature::SDK::EvaluationContext.new(
  targeting_key: "user_123",
  variable_key: "button_text"
)
result = client.fetch_string_details(flag_key: "checkout", default_value: "Buy", evaluation_context: context)
```

### Auto-detection

If a flag has only one variable matching the requested type, it is automatically selected:

```ruby
# If "checkout" has a single string variable, it's auto-detected
result = client.fetch_string_details(flag_key: "checkout", default_value: "Buy", evaluation_context: context)
```

### Passing user attributes

Fields in the evaluation context (other than `targeting_key` and `variable_key`) are passed as Optimizely user attributes:

```ruby
context = OpenFeature::SDK::EvaluationContext.new(
  targeting_key: "user_123",
  plan: "premium",
  country: "US"
)
```

### Shutdown

```ruby
provider.shutdown
```

## Configuration options

| Option | Type | Required | Description |
|---|---|---|---|
| `sdk_key` | String | One of `sdk_key` or `optimizely_client` | Optimizely SDK key |
| `optimizely_client` | Optimizely::Project | One of `sdk_key` or `optimizely_client` | Pre-built Optimizely client |
| `decide_options` | Array | No | Optimizely decide options (default: `[]`) |

## Variable key resolution order

1. `evaluation_context.fields["variable_key"]` -- explicit override
2. Dotted notation in `flag_key` -- `"flag.variable"` splits on first `.`
3. Auto-detect -- single variable matching the requested type

## License

Apache-2.0
