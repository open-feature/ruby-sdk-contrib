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

The `OpenFeature::FlagD` supports multiple configuration options that dictate how the SDK communicates with flagd.
Options can be defined in the constructor or as environment variables, with constructor options having the highest precedence.

### Available options

| Option name       | Environment variable name | Type    | Default   |
| -----------       | ------------------------- | ------- | --------- |
| host              | FLAGD_HOST                | string  | localhost |
| port              | FLAGD_PORT                | number  | 8013      |
| tls               | FLAGD_TLS                 | boolean | false     |
| unix_socket_path  | FLAGD_SOCKET_PATH         | string  | nil       |
| root_cert_path    | FLAGD_SERVER_CERT_PATH    | string  | nil       |

### Example using TCP

```ruby
OpenFeature::SDK.configure do |config|
    # your provider of choice
    config.provider = OpenFeature::FlagD::Provider.configure do |provider_config|
        provider_config.host = "localhost"
        provider_config.port = 8013
        provider_config.tls = false
    end
end
```

### Example using a Unix socket

```ruby
OpenFeature::SDK.configure do |config|
    # your provider of choice
    config.provider = OpenFeature::FlagD::Provider.configure do |provider_config|
        provider_config.unix_socket_path = "tmp/flagd.sock"
    end
end
```


### Example using a secure connection

```ruby
OpenFeature::SDK.configure do |config|
    # your provider of choice
    config.provider = OpenFeature::FlagD::Provider.configure do |provider_config|
        provider_config.host = "localhost"
        provider_config.port = 8013
        provider_config.tls = true
        provider_config.root_cert_path = './ca.pem'
    end
end
```


If no environment variables are set the [default configuration](./lib/openfeature/flagd/provider/configuration.rb) is set

## Contributing

https://github.com/open-feature/ruby-sdk-contrib
