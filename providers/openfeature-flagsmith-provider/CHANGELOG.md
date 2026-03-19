# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.3](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-flagsmith-provider/v0.1.2...openfeature-flagsmith-provider/v0.1.3) (2026-03-18)


### 🧹 Chore

* **deps:** update dependency ruby to v3.4.9 ([#107](https://github.com/open-feature/ruby-sdk-contrib/issues/107)) ([e0d4314](https://github.com/open-feature/ruby-sdk-contrib/commit/e0d4314f1183cc80e84ba04980fe2d01584bec9c))

## [0.1.2](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-flagsmith-provider/v0.1.1...openfeature-flagsmith-provider/v0.1.2) (2026-03-09)


### ✨ New Features

* add OFREP provider ([#80](https://github.com/open-feature/ruby-sdk-contrib/issues/80)) ([e33e0ab](https://github.com/open-feature/ruby-sdk-contrib/commit/e33e0ab340193eee4434df65bb33e1002a69eaad))


### 🧹 Chore

* add conformance tests, SimpleCov, version standardization, and README improvements ([#95](https://github.com/open-feature/ruby-sdk-contrib/issues/95)) ([1c430a9](https://github.com/open-feature/ruby-sdk-contrib/commit/1c430a92041a7841ac01a2642a66376b8259acd2))
* improve repository maturity and contributor experience ([#91](https://github.com/open-feature/ruby-sdk-contrib/issues/91)) ([7e28025](https://github.com/open-feature/ruby-sdk-contrib/commit/7e280257e6f543bc46537f43aeac302be003b47b))
* update minimum Ruby version to &gt;= 3.4 ([#83](https://github.com/open-feature/ruby-sdk-contrib/issues/83)) ([ccf689a](https://github.com/open-feature/ruby-sdk-contrib/commit/ccf689a097de8d7db86fffd84b2127ac75687d4c))

## [0.1.1](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-flagsmith-provider-v0.1.0...openfeature-flagsmith-provider/v0.1.1) (2025-11-27)


### ✨ New Features

* add flagsmith provider ([#68](https://github.com/open-feature/ruby-sdk-contrib/issues/68)) ([9e3216a](https://github.com/open-feature/ruby-sdk-contrib/commit/9e3216ac67d1eeb12f423a4c0615442ac52b2a17))

## [Unreleased]

### Added
- Initial implementation of Flagsmith OpenFeature provider
- Support for all OpenFeature flag types (boolean, string, number, integer, float, object)
- Remote and local evaluation modes
- Environment-level and identity-specific flag evaluation
- Comprehensive error handling and type validation
