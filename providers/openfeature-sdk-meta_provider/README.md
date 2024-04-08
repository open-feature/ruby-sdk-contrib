# OpenFeature::SDK::Provider::MetaProvider for Ruby

The `OpenFeature::SDK::Provider::MetaProvider` is a utility provider implementation that takes multiple [providers](https://docs.openfeature.dev/docs/specification/sections/providers) for use during flag resolution.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'openfeature-meta-provider'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install openfeature-meta-provider
```

## Usage

The `MetaProvider` is initialized with a collection of `Provider`s and a strategy for fetching flags from them.

```ruby
# Create a MetaProvider
meta_provider = OpenFeature::SDK::Provider::MetaProvider.new(
  providers: [
    OpenFeature::SDK::ProviderInMemoryProvider.new,
    MyCustomProvider.new
  ],
  strategy: :first_match
)

# Use it as the default provider
OpenFeature.configure do |c|
  c.set_provider(meta_provider)
end
```

### Strategies

#### :first_match

When `:first_match` is given as the strategy, each provider will be evaluated, in the order they were passed in, for the requested `flag_key`. The first provider where the `flag_key` is found will be returned, short-circuiting flag evaluation with the remaining providers. In the case of a provider error, or no matching flags, returns the default value.


## Contributing

https://github.com/open-feature/ruby-sdk-contrib
