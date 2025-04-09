<p align="center">
  <img width="400" src="https://raw.githubusercontent.com/flipt-io/flipt/main/logo.svg" alt="flipt logo" />
</p>

# Flipt - OpenFeature Ruby provider

This repository contains the Ruby provider for [Flipt](https://www.flipt.io/), a feature flagging and experimentation platform.

In conjunction with the [OpenFeature SDK](https://openfeature.dev/docs/reference/concepts/provider/) you can use this provider to integrate Flipt into your Ruby application.

For documentation on how to use Flipt, please refer to the [Flipt documentation](https://docs.flipt.io/).

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'openfeature-flipt-provider'
```

And then execute:
```bash
$ bundle
```

## Usage
To use the Flipt provider, you need to create an instance of the provider and pass it to the OpenFeature SDK.

```ruby
require "open_feature/sdk"
require "openfeature/flipt/provider"

OpenFeature::SDK.configure do |config|
  config.set_provider(
    OpenFeature::Flipt::Provider.new(options: {
      url: "http://url-to-flipt-server"
    })
  )
end
client = OpenFeature::SDK.build_client

# Check if a feature is enabled
if client.fetch_boolean_value(flag_key: "featureEnabled", default_value: false)
  puts "Feature is enabled"
else
  puts "Feature is disabled"
end
```

## Contributing
https://github.com/open-feature/ruby-sdk-contrib
