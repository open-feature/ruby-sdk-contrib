# Changelog

## [0.1.0](https://github.com/open-feature/ruby-sdk-contrib/tree/main/providers/openfeature-optimizely-provider) (2026-03-18)

### Features

* Initial release of the OpenFeature Optimizely provider for Ruby
* Support for boolean, string, number (integer/float), and object flag evaluations
* Dotted notation for accessing Optimizely feature variables (e.g., `flag_key.variable_key`)
* Context-based variable key override via `variable_key` field
* Auto-detection of single typed variables
* Full lifecycle management (init/shutdown) for Optimizely client
