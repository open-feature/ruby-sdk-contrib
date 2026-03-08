# frozen_string_literal: true

require_relative "lib/openfeature/otel/hook/version"

Gem::Specification.new do |spec|
  spec.name = "openfeature-otel-hook"
  spec.version = OpenFeature::OTel::Hook::VERSION
  spec.authors = ["OpenFeature Contributors"]
  spec.email = ["cncf-openfeature-contributors@lists.cncf.io"]

  spec.summary = "OpenTelemetry hooks for the OpenFeature Ruby SDK"
  spec.description = "Traces and metrics hooks that emit OpenTelemetry signals for OpenFeature flag evaluations"
  spec.homepage = "https://github.com/open-feature/ruby-sdk-contrib/tree/main/hooks/openfeature-otel-hook"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 3.4"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/issues"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "openfeature-sdk", "~> 0.6"
  spec.add_runtime_dependency "opentelemetry-api", "~> 1.0"

  spec.add_development_dependency "opentelemetry-sdk", "~> 1.0"
  spec.add_development_dependency "opentelemetry-metrics-sdk"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "standard", "~> 1.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
end
