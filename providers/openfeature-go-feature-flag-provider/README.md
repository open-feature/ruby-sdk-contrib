<p align="center">
  <img width="400" src="https://raw.githubusercontent.com/thomaspoignant/go-feature-flag/main/gofeatureflag.svg" alt="go-feature-flag logo" />

</p>

# GO Feature Flag - OpenFeature Ruby provider
<p align="center">
   <a href="https://github.com/open-feature/ruby-sdk-contrib/tree/main/providers/openfeature-go-feature-flag-provider"><img src="https://img.shields.io/gem/v/openfeature-go-feature-flag-provider?color=blue&style=flat-square&logo=ruby" alt="gem"></a>
   <a href="https://gofeatureflag.org/"><img src="https://img.shields.io/badge/%F0%9F%93%92-Website-blue" alt="Documentation"></a>
   <a href="https://github.com/thomaspoignant/go-feature-flag/issues"><img src="https://img.shields.io/badge/%E2%9C%8F%EF%B8%8F-issues-red" alt="Issues"></a>
   <a href="https://gofeatureflag.org/slack"><img src="https://img.shields.io/badge/join-us%20on%20slack-gray.svg?longCache=true&logo=slack&colorB=green" alt="Join us on slack"></a>
</p>

This repository contains the official Ruby OpenFeature provider for accessing your feature flags with [GO Feature Flag](https://gofeatureflag.org).

In conjunction with the [OpenFeature SDK](https://openfeature.dev/docs/reference/concepts/provider) you will be able
to evaluate your feature flags in your Ruby applications.

For documentation related to flags management in GO Feature Flag,
refer to the [GO Feature Flag documentation website](https://gofeatureflag.org/docs).

### Functionalities:
- Manage the integration of the OpenFeature Ruby SDK and GO Feature Flag relay-proxy.

## Dependency Setup

### Gem Package Manager

Add this line to your application's Gemfile:
```
gem 'openfeature-go-feature-flag-provider'
```
And then execute:
```
bundle install
```
Or install it yourself as:
```
gem install openfeature-go-feature-flag-provider
```

## Getting started

### Initialize the provider

The `OpenFeature::GoFeatureFlag::Provider` needs some options to be created and then set in the OpenFeature SDK.

| **Option**        | **Description**                                                                                                                             |
|-------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| `endpoint`        | **(mandatory)** The URL to access to the relay-proxy.<br />*(example: `https://relay.proxy.gofeatureflag.org/`)*                            |
| `headers`         | A `Hash` object containing the headers to send to the relay-proxy.<br/>*(example to send APIKey: `{"Authorization" => "Bearer my-api-key"}` |
| `instrumentation` | [Faraday instrumentation](https://github.com/lostisland/faraday/blob/main/docs/middleware/included/instrumentation.md) hash                 |
The only required option to create a `GoFeatureFlagProvider` is the URL _(`endpoint`)_ to your GO Feature Flag relay-proxy instance.

```ruby
options = OpenFeature::GoFeatureFlag::Options.new(endpoint: "http://localhost:1031")
provider = OpenFeature::GoFeatureFlag::Provider.new(options:)

evaluation_context = OpenFeature::SDK::EvaluationContext.new(targeting_key: "9b9450f8-ab5c-4dcf-872f-feda3f6ccb16")

OpenFeature::SDK.configure do |config|
   config.set_provider(provider)
end
client = OpenFeature::SDK.build_client

bool_value = client.fetch_boolean_value(
  flag_key: "my-boolean-flag",
  default_value: false,
  evaluation_context:
)

if bool_value 
  puts "The flag is enabled"
else
  puts "The flag is disabled"
end
```

The evaluation context is the way for the client to specify contextual data that GO Feature Flag uses to evaluate the feature flags, it allows to define rules on the flag.

The `targeting_key` is mandatory for GO Feature Flag to evaluate the feature flag, it could be the id of a user, a session ID or anything you find relevant to use as identifier during the evaluation.


### Evaluate a feature flag
The client is used to retrieve values for the current `EvaluationContext`. 
For example, retrieving a boolean value for the flag **"my-flag"**:

```ruby
client = OpenFeature::SDK.build_client

bool_value = client.fetch_boolean_value(
  flag_key: "my-boolean-flag",
  default_value: false,
  evaluation_context: evaluation_context
)
```

GO Feature Flag supports different all OpenFeature supported types of feature flags, it means that you can use all the accessor directly
```ruby
# Bool
client.fetch_boolean_value(flag_key: 'my-flag', default_value: false, evaluation_context:)

# String
client.fetch_string_value(flag_key: 'my-flag', default_value: "default", evaluation_context:)

# Number
client.fetch_number_value(flag_key: 'my-flag', default_value: 0, evaluation_context:)

# Object
client.fetch_object_value(flag_key: 'my-flag', default_value: {"default" => true}, evaluation_context:)
```

## Features status

| Status | Feature         | Description                                                                |
|--------|-----------------|----------------------------------------------------------------------------|
| ✅      | Flag evaluation | It is possible to evaluate all the type of flags                           |
| ❌      | Caching         | Mechanism is in place to refresh the cache in case of configuration change |
| ❌      | Event Streaming | Not supported by the SDK                                                   |
| ❌      | Logging         | Not supported by the SDK                                                   |
| ✅      | Flag Metadata   | You can retrieve your flag metadata directly in the evaluation details.    |


<sub>**Implemented**: ✅ | In-progress: ⚠️ | Not implemented yet: ❌</sub>

## Contributing
This project welcomes contributions from the community.
If you're interested in contributing, see the [contributors' guide](https://github.com/thomaspoignant/go-feature-flag/blob/main/CONTRIBUTING.md) for some helpful tips.
