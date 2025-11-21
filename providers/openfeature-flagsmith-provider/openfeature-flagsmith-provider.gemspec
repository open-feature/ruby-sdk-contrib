require_relative "lib/openfeature/flagsmith/version"

Gem::Specification.new do |spec|
  spec.name = "openfeature-flagsmith-provider"
  spec.version = OpenFeature::Flagsmith::VERSION
  spec.authors = ["OpenFeature Contributors"]
  spec.email = ["cncf-openfeature-contributors@lists.cncf.io"]

  spec.summary = "OpenFeature provider for Flagsmith"
  spec.description = "Flagsmith provider for the OpenFeature Ruby SDK"
  spec.homepage = "https://github.com/open-feature/ruby-sdk-contrib/tree/main/providers/openfeature-flagsmith-provider"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/issues"
  spec.metadata["documentation_uri"] = "#{spec.homepage}/README.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_runtime_dependency "openfeature-sdk", "~> 0.3.1"
  spec.add_runtime_dependency "flagsmith", "~> 4.3"

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12.0"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "standard", "~> 1.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "simplecov", "~> 0.22"
end
