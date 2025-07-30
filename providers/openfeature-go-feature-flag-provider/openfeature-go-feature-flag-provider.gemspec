# frozen_string_literal: true

require_relative "lib/openfeature/go-feature-flag/version"

Gem::Specification.new do |spec|
  spec.name = "openfeature-go-feature-flag-provider"
  spec.version = OpenFeature::GoFeatureFlag::GO_FEATURE_FLAG_PROVIDER_VERSION
  spec.authors = ["Thomas Poignant"]
  spec.email = ["contact@gofeatureflag.org"]

  spec.summary = "The GO Feature Flag provider for the OpenFeature Ruby SDK"
  spec.description = "The GO Feature Flag provider for the OpenFeature Ruby SDK"
  spec.homepage = "https://github.com/open-feature/ruby-sdk-contrib/tree/main/providers/openfeature-go-feature-flag-provider"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/tree/main/providers/openfeature-go-feature-flag-provider"
  spec.metadata["changelog_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/blob/main/providers/openfeature-go-feature-flag-provider/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/thomaspoignant/go-feature-flag/issues/new/choose"
  spec.metadata["documentation_uri"] = "https://gofeatureflag.org/docs"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "openfeature-sdk", "~> 0.3.1"
  spec.add_runtime_dependency "faraday-net_http_persistent", "~> 2.3"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12.0"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "webmock"
end
