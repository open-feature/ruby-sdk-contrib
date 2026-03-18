# Changelog

## [0.1.7](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-flagd-provider/v0.1.6...openfeature-flagd-provider/v0.1.7) (2026-03-18)


### 🧹 Chore

* **deps:** update dependency ruby to v3.4.9 ([#107](https://github.com/open-feature/ruby-sdk-contrib/issues/107)) ([e0d4314](https://github.com/open-feature/ruby-sdk-contrib/commit/e0d4314f1183cc80e84ba04980fe2d01584bec9c))

## [0.1.6](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-flagd-provider/v0.1.5...openfeature-flagd-provider/v0.1.6) (2026-03-09)


### 🐛 Bug Fixes

* **flagd:** delegate method() through ConfiguredClient for conformance ([51fcb5b](https://github.com/open-feature/ruby-sdk-contrib/commit/51fcb5bd4e22d249cd18ef6bd13b37572e6c1d94))

## [0.1.5](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-flagd-provider/v0.1.4...openfeature-flagd-provider/v0.1.5) (2026-03-09)


### ✨ New Features

* add OFREP provider ([#80](https://github.com/open-feature/ruby-sdk-contrib/issues/80)) ([e33e0ab](https://github.com/open-feature/ruby-sdk-contrib/commit/e33e0ab340193eee4434df65bb33e1002a69eaad))


### 🧹 Chore

* add conformance tests, SimpleCov, version standardization, and README improvements ([#95](https://github.com/open-feature/ruby-sdk-contrib/issues/95)) ([1c430a9](https://github.com/open-feature/ruby-sdk-contrib/commit/1c430a92041a7841ac01a2642a66376b8259acd2))
* improve repository maturity and contributor experience ([#91](https://github.com/open-feature/ruby-sdk-contrib/issues/91)) ([7e28025](https://github.com/open-feature/ruby-sdk-contrib/commit/7e280257e6f543bc46537f43aeac302be003b47b))

## [0.1.4](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-flagd-provider/v0.1.3...openfeature-flagd-provider/v0.1.4) (2026-03-08)


### 🧹 Chore

* update minimum Ruby version to &gt;= 3.4 ([#83](https://github.com/open-feature/ruby-sdk-contrib/issues/83)) ([ccf689a](https://github.com/open-feature/ruby-sdk-contrib/commit/ccf689a097de8d7db86fffd84b2127ac75687d4c))

## [0.1.3](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-flagd-provider/v0.1.2...openfeature-flagd-provider/v0.1.3) (2026-03-07)


### ✨ New Features

* **flagd:** support kwargs configuration and add lazy root_cert reader ([#78](https://github.com/open-feature/ruby-sdk-contrib/issues/78)) ([981f6fc](https://github.com/open-feature/ruby-sdk-contrib/commit/981f6fc95160cda80df87e062f5bfbbb73e770b5))

## [0.1.2](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-flagd-provider/v0.1.1...openfeature-flagd-provider/v0.1.2) (2024-08-29)


### 🐛 Bug Fixes

* Fractional evaluation ([#41](https://github.com/open-feature/ruby-sdk-contrib/issues/41)) ([5bb34f2](https://github.com/open-feature/ruby-sdk-contrib/commit/5bb34f2f1cd880e0bc77597594cb33a2dba092e6))

## [0.1.1](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-flagd-provider/v0.1.0...openfeature-flagd-provider/v0.1.1) (2024-07-11)


### ✨ New Features

* Use integer and float specific resolver methods ([#26](https://github.com/open-feature/ruby-sdk-contrib/issues/26)) ([6baa243](https://github.com/open-feature/ruby-sdk-contrib/commit/6baa243f7586d65796fdba9a567352c66d100fde))


### 🧹 Chore

* **flagd:** update spec metadata links ([#36](https://github.com/open-feature/ruby-sdk-contrib/issues/36)) ([400d625](https://github.com/open-feature/ruby-sdk-contrib/commit/400d6254c164b8c3623bf2b18c5bea66580b0b1a))

## [0.1.0](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-flagd-provider-v0.0.1...openfeature-flagd-provider/v0.1.0) (2024-05-16)


### ⚠ BREAKING CHANGES

* update flagd name and grpc schema ([#30](https://github.com/open-feature/ruby-sdk-contrib/issues/30))

### ✨ New Features

* Add flagd provider ([#2](https://github.com/open-feature/ruby-sdk-contrib/issues/2)) ([98b695b](https://github.com/open-feature/ruby-sdk-contrib/commit/98b695b05eb1525cb796479be8b36c2751297b98))
* Add support for unix socket path and secure connection ([#8](https://github.com/open-feature/ruby-sdk-contrib/issues/8)) ([88436c7](https://github.com/open-feature/ruby-sdk-contrib/commit/88436c7175373552bc7cad236297028bb655e12d))
* Flagd provider uses structs from sdk ([#24](https://github.com/open-feature/ruby-sdk-contrib/issues/24)) ([d437e7f](https://github.com/open-feature/ruby-sdk-contrib/commit/d437e7f72f3790d6c82ce1d006efdd528da7402e))
* integrate flagd provider with OpenFeature SDK ([#18](https://github.com/open-feature/ruby-sdk-contrib/issues/18)) ([80d6d02](https://github.com/open-feature/ruby-sdk-contrib/commit/80d6d028fbe762fae243d687bba7f9642bb2c116))
* Return default value on error ([#25](https://github.com/open-feature/ruby-sdk-contrib/issues/25)) ([f365c6d](https://github.com/open-feature/ruby-sdk-contrib/commit/f365c6db6ab8465c39d55764c7715f81d6d7f922))
* update flagd name and grpc schema ([#30](https://github.com/open-feature/ruby-sdk-contrib/issues/30)) ([ddd438a](https://github.com/open-feature/ruby-sdk-contrib/commit/ddd438abc3c7b6d586c36ea94060c75448e99f27))


### 🧹 Chore

* Format with standard ([#20](https://github.com/open-feature/ruby-sdk-contrib/issues/20)) ([bf25043](https://github.com/open-feature/ruby-sdk-contrib/commit/bf25043f87bdd9cd2bc8527fead8f4a0c3b95eff))
* Make things work ([#13](https://github.com/open-feature/ruby-sdk-contrib/issues/13)) ([5968037](https://github.com/open-feature/ruby-sdk-contrib/commit/5968037b7290f7f84ca96e621bf136f7c7a42e8a))
* update link to use new doc domain ([#12](https://github.com/open-feature/ruby-sdk-contrib/issues/12)) ([9baff65](https://github.com/open-feature/ruby-sdk-contrib/commit/9baff65051522705606e336ba1fe614115907418))
* upgrade grpc client ([#16](https://github.com/open-feature/ruby-sdk-contrib/issues/16)) ([23ed78a](https://github.com/open-feature/ruby-sdk-contrib/commit/23ed78a830c81030e1fb40d0aef04ea5458d2d6d))


### 🔄 Refactoring

* OpenFeature::FlagD::Provider::Configuration ([#14](https://github.com/open-feature/ruby-sdk-contrib/issues/14)) ([3686eb5](https://github.com/open-feature/ruby-sdk-contrib/commit/3686eb5c31ec0e6af97bc74ff58ffb815b78e114))
