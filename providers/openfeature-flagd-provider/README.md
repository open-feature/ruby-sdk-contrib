# OpenFeature FlagD Provider for Ruby

This is the Ruby [provider](https://docs.openfeature.dev/docs/specification/sections/providers) implementation of the [FlagD](https://github.com/open-feature/flagd)
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'openfeature-flagd-provider'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install openfeature-flagd-provider
```

## Usage

The provider allows for configuration of host, port, socket_path, and tls connection.

```ruby
OpenFeature::FlagD::Provider.configure do |config|
    config.host = "localhost"
    config.port = 8013
    config.tls = false
end
```

If no configurations are provided, the provider will be initialized with the following environment variables:

> FLAGD_HOST
> FLAGD_PORT
> FLAGD_TLS
> FLAGD_SOCKET_PATH

If no environment variables are set the [default configuration](./lib/openfeature/flagd/provider/configuration.rb) is set

## Contributing

https://github.com/open-feature/ruby-sdk-contrib
