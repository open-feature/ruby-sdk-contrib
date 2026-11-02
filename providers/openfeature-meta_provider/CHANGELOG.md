# Changelog

## [0.1.2](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-meta_provider/v0.1.1...openfeature-meta_provider/v0.1.2) (2026-11-02)


### 🧹 Chore

* **deps:** lock file maintenance ([#234](https://github.com/open-feature/ruby-sdk-contrib/issues/234)) ([402c691](https://github.com/open-feature/ruby-sdk-contrib/commit/402c6913534128605eb2bd4cad870c31cff2d7c0))
* **deps:** lock file maintenance ([#242](https://github.com/open-feature/ruby-sdk-contrib/issues/242)) ([788b51c](https://github.com/open-feature/ruby-sdk-contrib/commit/788b51c34300d0654fa837bfd15a86d56a7ac142))
* **deps:** lock file maintenance ([#248](https://github.com/open-feature/ruby-sdk-contrib/issues/248)) ([24d69f1](https://github.com/open-feature/ruby-sdk-contrib/commit/24d69f1ce10a461a9e86971ffa3d579394894145))
* **deps:** lock file maintenance ([#251](https://github.com/open-feature/ruby-sdk-contrib/issues/251)) ([a351265](https://github.com/open-feature/ruby-sdk-contrib/commit/a3512650043f83c8be7e224d9797c639ddc3a4f0))
* **deps:** lock file maintenance ([#259](https://github.com/open-feature/ruby-sdk-contrib/issues/259)) ([ffe7663](https://github.com/open-feature/ruby-sdk-contrib/commit/ffe7663ffef575202abe21b94f196076a49b3ad1))
* **deps:** lock file maintenance ([#277](https://github.com/open-feature/ruby-sdk-contrib/issues/277)) ([857f47f](https://github.com/open-feature/ruby-sdk-contrib/commit/857f47f679bfa29454dd899ef40040c08a69dd13))
* **deps:** lock file maintenance ([#284](https://github.com/open-feature/ruby-sdk-contrib/issues/284)) ([73f1ac8](https://github.com/open-feature/ruby-sdk-contrib/commit/73f1ac8372d698d0c913383b4c923b41620bc3be))
* **deps:** update dependency ruby to v4 ([#124](https://github.com/open-feature/ruby-sdk-contrib/issues/124)) ([f6fdaf6](https://github.com/open-feature/ruby-sdk-contrib/commit/f6fdaf6c304f730960e379ec7042657916a7ae44))
* **deps:** update dependency ruby to v4.0.3 ([#161](https://github.com/open-feature/ruby-sdk-contrib/issues/161)) ([538486e](https://github.com/open-feature/ruby-sdk-contrib/commit/538486e8b6a42979c35a251f12e94292f412f8a0))
* **deps:** update dependency ruby to v4.0.4 ([#170](https://github.com/open-feature/ruby-sdk-contrib/issues/170)) ([0bde1a8](https://github.com/open-feature/ruby-sdk-contrib/commit/0bde1a85b475764deb22b56d34e1e333a809ec37))
* **deps:** update dependency ruby to v4.0.5 ([#173](https://github.com/open-feature/ruby-sdk-contrib/issues/173)) ([d410cee](https://github.com/open-feature/ruby-sdk-contrib/commit/d410ceeed7c77ea2626d009c052ed53d2621e511))
* **deps:** update dependency ruby to v4.0.6 ([#194](https://github.com/open-feature/ruby-sdk-contrib/issues/194)) ([c786a79](https://github.com/open-feature/ruby-sdk-contrib/commit/c786a7972924b7feee9321fd20062bb17ca2caea))
* **deps:** update dependency ruby to v4.0.7 ([#219](https://github.com/open-feature/ruby-sdk-contrib/issues/219)) ([74e1acb](https://github.com/open-feature/ruby-sdk-contrib/commit/74e1acb0bab6d20d74107da95a6472daff0c0da4))
* **deps:** update dependency ruby to v4.0.8 ([#272](https://github.com/open-feature/ruby-sdk-contrib/issues/272)) ([003d193](https://github.com/open-feature/ruby-sdk-contrib/commit/003d193e84e4c27639405d2cfe83680f0aa0c21b))
* **deps:** update dependency ruby to v4.0.9 ([#276](https://github.com/open-feature/ruby-sdk-contrib/issues/276)) ([feaca24](https://github.com/open-feature/ruby-sdk-contrib/commit/feaca24ef5f68442132750137c73a49780eabc3a))
* resolve open dependabot security alerts ([#180](https://github.com/open-feature/ruby-sdk-contrib/issues/180)) ([b96958f](https://github.com/open-feature/ruby-sdk-contrib/commit/b96958ffd4603caf8b64dcf432a729a44289afc0))
* resolve open dependabot security alerts ([#203](https://github.com/open-feature/ruby-sdk-contrib/issues/203)) ([a1ab3a3](https://github.com/open-feature/ruby-sdk-contrib/commit/a1ab3a38f8221ea822792f098c5213a071c01d68))


### 🚀 Performance

* freeze provider metadata so hooks skip the per-evaluation copy ([#274](https://github.com/open-feature/ruby-sdk-contrib/issues/274)) ([7a13862](https://github.com/open-feature/ruby-sdk-contrib/commit/7a138628c2b09e32631786669cfa3255b0ec4c40))


### 🛠️ Build

* **flagd:** generate grpc bindings at build time ([#215](https://github.com/open-feature/ruby-sdk-contrib/issues/215)) ([afd0d8c](https://github.com/open-feature/ruby-sdk-contrib/commit/afd0d8c35ad374d161cd9d342c8c156f7a033a37))

## [0.1.1](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-meta_provider-v0.1.0...openfeature-meta_provider/v0.1.1) (2026-03-18)


### 🐛 Bug Fixes

* don't init if provider doesn't have an init method ([#49](https://github.com/open-feature/ruby-sdk-contrib/issues/49)) ([d2479ed](https://github.com/open-feature/ruby-sdk-contrib/commit/d2479edb27234b201453bb5fad12cc56c6c750de))


### ✨ New Features

* add matched provider to flag metadata in MetaProvider ([#31](https://github.com/open-feature/ruby-sdk-contrib/issues/31)) ([d48b182](https://github.com/open-feature/ruby-sdk-contrib/commit/d48b18253c1e23ac35c4d75edaaa7b89c6cc504b))
* add OFREP provider ([#80](https://github.com/open-feature/ruby-sdk-contrib/issues/80)) ([e33e0ab](https://github.com/open-feature/ruby-sdk-contrib/commit/e33e0ab340193eee4434df65bb33e1002a69eaad))
* **meta_provider:** add multi-provider evaluation strategies ([#102](https://github.com/open-feature/ruby-sdk-contrib/issues/102)) ([9cce3f4](https://github.com/open-feature/ruby-sdk-contrib/commit/9cce3f4a0b075e853ce2c1f9a07f3ddc4c58044f))


### 🧹 Chore

* add conformance tests, SimpleCov, version standardization, and README improvements ([#95](https://github.com/open-feature/ruby-sdk-contrib/issues/95)) ([1c430a9](https://github.com/open-feature/ruby-sdk-contrib/commit/1c430a92041a7841ac01a2642a66376b8259acd2))
* **deps:** update dependency ruby to v3.4.9 ([#107](https://github.com/open-feature/ruby-sdk-contrib/issues/107)) ([e0d4314](https://github.com/open-feature/ruby-sdk-contrib/commit/e0d4314f1183cc80e84ba04980fe2d01584bec9c))
* improve repository maturity and contributor experience ([#91](https://github.com/open-feature/ruby-sdk-contrib/issues/91)) ([7e28025](https://github.com/open-feature/ruby-sdk-contrib/commit/7e280257e6f543bc46537f43aeac302be003b47b))
* **main:** release openfeature-meta_provider 0.0.2 ([#32](https://github.com/open-feature/ruby-sdk-contrib/issues/32)) ([6b63b49](https://github.com/open-feature/ruby-sdk-contrib/commit/6b63b49a42f3349e105613d1c209b9b44c2add5e))
* **main:** release openfeature-meta_provider 0.0.3 ([#35](https://github.com/open-feature/ruby-sdk-contrib/issues/35)) ([ca82b95](https://github.com/open-feature/ruby-sdk-contrib/commit/ca82b9586e81ea0f6c92c265f40c4bf3de694d16))
* **main:** release openfeature-meta_provider 0.0.4 ([#48](https://github.com/open-feature/ruby-sdk-contrib/issues/48)) ([456d35e](https://github.com/open-feature/ruby-sdk-contrib/commit/456d35e530ee5903be818c599788e8e4b1be5386))
* **main:** release openfeature-meta_provider 0.0.5 ([#50](https://github.com/open-feature/ruby-sdk-contrib/issues/50)) ([4015ba2](https://github.com/open-feature/ruby-sdk-contrib/commit/4015ba259dede2519a915679497c1f2d215d347f))
* **main:** release openfeature-meta_provider 0.0.6 ([#88](https://github.com/open-feature/ruby-sdk-contrib/issues/88)) ([f21b22f](https://github.com/open-feature/ruby-sdk-contrib/commit/f21b22ffa8b316e85d1cd233b2fb053d300b2b27))
* **main:** release openfeature-meta_provider 0.0.7 ([#97](https://github.com/open-feature/ruby-sdk-contrib/issues/97)) ([71a7c48](https://github.com/open-feature/ruby-sdk-contrib/commit/71a7c4882fccbdbc546677438d135d8927139016))
* update minimum Ruby version to &gt;= 3.4 ([#83](https://github.com/open-feature/ruby-sdk-contrib/issues/83)) ([ccf689a](https://github.com/open-feature/ruby-sdk-contrib/commit/ccf689a097de8d7db86fffd84b2127ac75687d4c))
* update readme title ([#34](https://github.com/open-feature/ruby-sdk-contrib/issues/34)) ([06f1517](https://github.com/open-feature/ruby-sdk-contrib/commit/06f1517f0e384b6b86d5aa7caedc6c3fd0bd74c7))


### 🛠️ Build

* **meta-provider:** Support non-breaking versions of openfeature-sdk ([#47](https://github.com/open-feature/ruby-sdk-contrib/issues/47)) ([5a98cf4](https://github.com/open-feature/ruby-sdk-contrib/commit/5a98cf4d540da39c6963a69d2c0772acad434b4b))

## [0.0.7](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-meta_provider/v0.0.6...openfeature-meta_provider/v0.0.7) (2026-03-09)


### ✨ New Features

* add OFREP provider ([#80](https://github.com/open-feature/ruby-sdk-contrib/issues/80)) ([e33e0ab](https://github.com/open-feature/ruby-sdk-contrib/commit/e33e0ab340193eee4434df65bb33e1002a69eaad))

## [0.0.6](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-meta_provider/v0.0.5...openfeature-meta_provider/v0.0.6) (2026-03-09)


### 🧹 Chore

* add conformance tests, SimpleCov, version standardization, and README improvements ([#95](https://github.com/open-feature/ruby-sdk-contrib/issues/95)) ([1c430a9](https://github.com/open-feature/ruby-sdk-contrib/commit/1c430a92041a7841ac01a2642a66376b8259acd2))
* improve repository maturity and contributor experience ([#91](https://github.com/open-feature/ruby-sdk-contrib/issues/91)) ([7e28025](https://github.com/open-feature/ruby-sdk-contrib/commit/7e280257e6f543bc46537f43aeac302be003b47b))
* update minimum Ruby version to &gt;= 3.4 ([#83](https://github.com/open-feature/ruby-sdk-contrib/issues/83)) ([ccf689a](https://github.com/open-feature/ruby-sdk-contrib/commit/ccf689a097de8d7db86fffd84b2127ac75687d4c))

## [0.0.5](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-meta_provider/v0.0.4...openfeature-meta_provider/v0.0.5) (2025-03-03)


### 🐛 Bug Fixes

* don't init if provider doesn't have an init method ([#49](https://github.com/open-feature/ruby-sdk-contrib/issues/49)) ([d2479ed](https://github.com/open-feature/ruby-sdk-contrib/commit/d2479edb27234b201453bb5fad12cc56c6c750de))

## [0.0.4](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-meta_provider/v0.0.3...openfeature-meta_provider/v0.0.4) (2025-02-28)


### 🛠️ Build

* **meta-provider:** Support non-breaking versions of openfeature-sdk ([#47](https://github.com/open-feature/ruby-sdk-contrib/issues/47)) ([5a98cf4](https://github.com/open-feature/ruby-sdk-contrib/commit/5a98cf4d540da39c6963a69d2c0772acad434b4b))

## [0.0.3](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-meta_provider/v0.0.2...openfeature-meta_provider/v0.0.3) (2024-05-16)


### 🧹 Chore

* update readme title ([#34](https://github.com/open-feature/ruby-sdk-contrib/issues/34)) ([06f1517](https://github.com/open-feature/ruby-sdk-contrib/commit/06f1517f0e384b6b86d5aa7caedc6c3fd0bd74c7))

## [0.0.2](https://github.com/open-feature/ruby-sdk-contrib/compare/openfeature-meta_provider-v0.0.1...openfeature-meta_provider/v0.0.2) (2024-05-14)


### ✨ New Features

* add matched provider to flag metadata in MetaProvider ([#31](https://github.com/open-feature/ruby-sdk-contrib/issues/31)) ([d48b182](https://github.com/open-feature/ruby-sdk-contrib/commit/d48b18253c1e23ac35c4d75edaaa7b89c6cc504b))
