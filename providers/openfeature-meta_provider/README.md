# OpenFeature::SDK::Provider::MetaProvider for Ruby

The `OpenFeature::SDK::Provider::MetaProvider` is a utility provider implementation that takes multiple [providers](https://docs.openfeature.dev/docs/specification/sections/providers) for use during flag resolution. This can be helpful when an organization is migrating or consolidating feature flag providers as they transition to OpenFeature. There are usually a combination of internal and vendor providers that are combined together to handle flag resolution. If your organization has different providers for different teams, consider looking at using [domains](https://openfeature.dev/specification/glossary#domain).

## Installation

Coming soon!

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
