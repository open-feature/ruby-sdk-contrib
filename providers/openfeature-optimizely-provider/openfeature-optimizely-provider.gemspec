# frozen_string_literal: true

require_relative "lib/openfeature/optimizely/provider/version"

Gem::Specification.new do |spec|
  spec.name = "openfeature-optimizely-provider"
  spec.version = OpenFeature::Optimizely::VERSION
  spec.authors = ["OpenFeature Contributors"]
  spec.email = ["cncf-openfeature-contributors@lists.cncf.io"]

  spec.summary = "OpenFeature provider for Optimizely"
  spec.description = "Optimizely provider for the OpenFeature Ruby SDK"
  spec.homepage = "https://github.com/open-feature/ruby-sdk-contrib/tree/main/providers/openfeature-optimizely-provider"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 3.4"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/tree/main/providers/openfeature-optimizely-provider"
  spec.metadata["changelog_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/blob/main/providers/openfeature-optimizely-provider/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/issues"
  spec.metadata["documentation_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/tree/main/providers/openfeature-optimizely-provider/README.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "logger"
  spec.add_runtime_dependency "openfeature-sdk", ">= 0.4.0", "< 1.0"
  spec.add_runtime_dependency "optimizely-sdk", "~> 5.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12.0"
  spec.add_development_dependency "standard", ">= 1.35.1"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "standard-performance"
  spec.add_development_dependency "simplecov", "~> 0.22"
end
