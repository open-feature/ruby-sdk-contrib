# Changelog

## [0.2.0](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-go-feature-flag-provider/v0.1.13...openfeature-go-feature-flag-provider/v0.2.0) (2026-11-11)


### ⚠ BREAKING CHANGES

* require Ruby >= 3.4 and test only on 3.4 and 4.0 ([#264](https://github.com/open-feature/ruby-sdk-contrib/issues/264))

### ✨ New Features

* support Ruby 3.3 (lower minimum from 3.4 to 3.3) ([#204](https://github.com/open-feature/ruby-sdk-contrib/issues/204)) ([295a34f](https://github.com/open-feature/ruby-sdk-contrib/commit/295a34f6d0bb4ff382362020a976ae0235e3ed53))


### 🧹 Chore

* **deps:** lock file maintenance ([#234](https://github.com/open-feature/ruby-sdk-contrib/issues/234)) ([402c691](https://github.com/open-feature/ruby-sdk-contrib/commit/402c6913534128605eb2bd4cad870c31cff2d7c0))
* **deps:** lock file maintenance ([#242](https://github.com/open-feature/ruby-sdk-contrib/issues/242)) ([788b51c](https://github.com/open-feature/ruby-sdk-contrib/commit/788b51c34300d0654fa837bfd15a86d56a7ac142))
* **deps:** lock file maintenance ([#248](https://github.com/open-feature/ruby-sdk-contrib/issues/248)) ([24d69f1](https://github.com/open-feature/ruby-sdk-contrib/commit/24d69f1ce10a461a9e86971ffa3d579394894145))
* **deps:** lock file maintenance ([#251](https://github.com/open-feature/ruby-sdk-contrib/issues/251)) ([a351265](https://github.com/open-feature/ruby-sdk-contrib/commit/a3512650043f83c8be7e224d9797c639ddc3a4f0))
* **deps:** lock file maintenance ([#259](https://github.com/open-feature/ruby-sdk-contrib/issues/259)) ([ffe7663](https://github.com/open-feature/ruby-sdk-contrib/commit/ffe7663ffef575202abe21b94f196076a49b3ad1))
* **deps:** lock file maintenance ([#277](https://github.com/open-feature/ruby-sdk-contrib/issues/277)) ([857f47f](https://github.com/open-feature/ruby-sdk-contrib/commit/857f47f679bfa29454dd899ef40040c08a69dd13))
* **deps:** lock file maintenance ([#284](https://github.com/open-feature/ruby-sdk-contrib/issues/284)) ([73f1ac8](https://github.com/open-feature/ruby-sdk-contrib/commit/73f1ac8372d698d0c913383b4c923b41620bc3be))
* **deps:** lock file maintenance ([#296](https://github.com/open-feature/ruby-sdk-contrib/issues/296)) ([1bb9318](https://github.com/open-feature/ruby-sdk-contrib/commit/1bb9318c57711d56913e6ce8a78ed3e83fe67a15))
* require Ruby &gt;= 3.4 and test only on 3.4 and 4.0 ([#264](https://github.com/open-feature/ruby-sdk-contrib/issues/264)) ([89489ce](https://github.com/open-feature/ruby-sdk-contrib/commit/89489ceb37f3d9dbebc29982a265bb7aeecc6af7))
* resolve open dependabot security alerts ([#180](https://github.com/open-feature/ruby-sdk-contrib/issues/180)) ([b96958f](https://github.com/open-feature/ruby-sdk-contrib/commit/b96958ffd4603caf8b64dcf432a729a44289afc0))
* resolve open dependabot security alerts ([#203](https://github.com/open-feature/ruby-sdk-contrib/issues/203)) ([a1ab3a3](https://github.com/open-feature/ruby-sdk-contrib/commit/a1ab3a38f8221ea822792f098c5213a071c01d68))


### 🚀 Performance

* freeze provider metadata so hooks skip the per-evaluation copy ([#274](https://github.com/open-feature/ruby-sdk-contrib/issues/274)) ([7a13862](https://github.com/open-feature/ruby-sdk-contrib/commit/7a138628c2b09e32631786669cfa3255b0ec4c40))


### 🛠️ Build

* **deps:** bump json from 2.19.1 to 2.19.2 in /providers/openfeature-go-feature-flag-provider ([#127](https://github.com/open-feature/ruby-sdk-contrib/issues/127)) ([d8b82b7](https://github.com/open-feature/ruby-sdk-contrib/commit/d8b82b706db5c5cc092e941ce638a8e19049e063))

## [0.1.13](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-go-feature-flag-provider/v0.1.12...openfeature-go-feature-flag-provider/v0.1.13) (2026-03-18)


### 🛠️ Build

* **deps:** bump faraday from 2.13.4 to 2.14.1 in /providers/openfeature-go-feature-flag-provider ([#114](https://github.com/open-feature/ruby-sdk-contrib/issues/114)) ([1da8add](https://github.com/open-feature/ruby-sdk-contrib/commit/1da8add491402bfd3ee202b6054f5116b44e000c))

## [0.1.12](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-go-feature-flag-provider/v0.1.11...openfeature-go-feature-flag-provider/v0.1.12) (2026-03-09)


### 🐛 Bug Fixes

* resolve flaky rate-limit date test and correct flipt version-file path ([f9fecc4](https://github.com/open-feature/ruby-sdk-contrib/commit/f9fecc4f303b9eee0b58216ca50073611af8e9ad))


### ✨ New Features

* add OFREP provider ([#80](https://github.com/open-feature/ruby-sdk-contrib/issues/80)) ([e33e0ab](https://github.com/open-feature/ruby-sdk-contrib/commit/e33e0ab340193eee4434df65bb33e1002a69eaad))

## [0.1.11](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-go-feature-flag-provider/v0.1.10...openfeature-go-feature-flag-provider/v0.1.11) (2026-03-09)


### 🧹 Chore

* add conformance tests, SimpleCov, version standardization, and README improvements ([#95](https://github.com/open-feature/ruby-sdk-contrib/issues/95)) ([1c430a9](https://github.com/open-feature/ruby-sdk-contrib/commit/1c430a92041a7841ac01a2642a66376b8259acd2))
* improve repository maturity and contributor experience ([#91](https://github.com/open-feature/ruby-sdk-contrib/issues/91)) ([7e28025](https://github.com/open-feature/ruby-sdk-contrib/commit/7e280257e6f543bc46537f43aeac302be003b47b))

## [0.1.10](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-go-feature-flag-provider/v0.1.9...openfeature-go-feature-flag-provider/v0.1.10) (2026-03-08)


### 🧹 Chore

* update minimum Ruby version to &gt;= 3.4 ([#83](https://github.com/open-feature/ruby-sdk-contrib/issues/83)) ([ccf689a](https://github.com/open-feature/ruby-sdk-contrib/commit/ccf689a097de8d7db86fffd84b2127ac75687d4c))

## [0.1.9](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-go-feature-flag-provider/v0.1.8...openfeature-go-feature-flag-provider/v0.1.9) (2026-01-28)


### ✨ New Features

* Timeout option for http client ([#76](https://github.com/open-feature/ruby-sdk-contrib/issues/76)) ([11e0de2](https://github.com/open-feature/ruby-sdk-contrib/commit/11e0de297527e90ee3dfcabf9d6bc35ff3149b9b))

## [0.1.8](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-go-feature-flag-provider/v0.1.7...openfeature-go-feature-flag-provider/v0.1.8) (2026-01-13)


### 🐛 Bug Fixes

* Make goff unix socket client thread safe ([#74](https://github.com/open-feature/ruby-sdk-contrib/issues/74)) ([ec25c37](https://github.com/open-feature/ruby-sdk-contrib/commit/ec25c3787b108ed2af8d7f1c9efbd6a258870a21))

## [0.1.7](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-go-feature-flag-provider/v0.1.6...openfeature-go-feature-flag-provider/v0.1.7) (2025-11-19)


### ✨ New Features

* **GoFeatureFlag:** unix client ([#66](https://github.com/open-feature/ruby-sdk-contrib/issues/66)) ([3f68ce8](https://github.com/open-feature/ruby-sdk-contrib/commit/3f68ce8691646779755affb2c86edf51ae21b40b))

## [0.1.6](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-go-feature-flag-provider/v0.1.5...openfeature-go-feature-flag-provider/v0.1.6) (2025-11-11)


### 🐛 Bug Fixes

* **openfeature-go-feature-flag-provider:** fallback to sdkDefault if reason is DISABLED ([#64](https://github.com/open-feature/ruby-sdk-contrib/issues/64)) ([6cb08c0](https://github.com/open-feature/ruby-sdk-contrib/commit/6cb08c0156ce1ee4ea17278937e6da8904a15d04))

## [0.1.5](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-go-feature-flag-provider/v0.1.4...openfeature-go-feature-flag-provider/v0.1.5) (2025-11-04)


### ✨ New Features

* **goff:** add Faraday instrumentation ([#62](https://github.com/open-feature/ruby-sdk-contrib/issues/62)) ([6ae223f](https://github.com/open-feature/ruby-sdk-contrib/commit/6ae223f3ffa076a45581f454cffbc49a0394d871))

## [0.1.4](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-go-feature-flag-provider/v0.1.3...openfeature-go-feature-flag-provider/v0.1.4) (2025-07-30)


### ✨ New Features

* connection persistance ([#59](https://github.com/open-feature/ruby-sdk-contrib/issues/59)) ([3a01a5e](https://github.com/open-feature/ruby-sdk-contrib/commit/3a01a5e4cc597aa0bc223e71f3e165f63c66f296))

## [0.1.3](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-go-feature-flag-provider/v0.1.2...openfeature-go-feature-flag-provider/v0.1.3) (2025-01-25)


### ✨ New Features

* **go-feature-flag:** Support exporter metadata ([#45](https://github.com/open-feature/ruby-sdk-contrib/issues/45)) ([04754fd](https://github.com/open-feature/ruby-sdk-contrib/commit/04754fd24e33ce993a9da3ddcaf84c34f9cb2342))

## [0.1.2](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-go-feature-flag-provider/v0.1.1...openfeature-go-feature-flag-provider/v0.1.2) (2024-12-02)


### 🐛 Bug Fixes

* loosen faraday version requirements ([#43](https://github.com/open-feature/ruby-sdk-contrib/issues/43)) ([df65efc](https://github.com/open-feature/ruby-sdk-contrib/commit/df65efc5c3c55536e2aa964fc075d89da8c19108))

## [0.1.1](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-go-feature-flag-provider-v0.1.0...openfeature-go-feature-flag-provider/v0.1.1) (2024-08-13)


### ✨ New Features

* new GO Feature Flag ruby provider ([#38](https://github.com/open-feature/ruby-sdk-contrib/issues/38)) ([a0bbf53](https://github.com/open-feature/ruby-sdk-contrib/commit/a0bbf535da324279b18577f71ffaa05d4f2fdced))
