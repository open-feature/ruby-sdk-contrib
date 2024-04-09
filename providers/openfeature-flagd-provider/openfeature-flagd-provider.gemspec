# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "openfeature-flagd-provider"
  spec.version = "0.0.1"
  spec.authors = ["OpenFeature Authors"]
  spec.email = ["cncf-openfeature-contributors@lists.cncf.io"]

  spec.summary = "The FlagD provider for the OpenFeature Ruby SDK"
  spec.description = "The FlagD provider for the OpenFeature Ruby SDK"
  spec.homepage = "https://github.com/open-feature/ruby-sdk-contrib/providers/openfeature-flagd-provider"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/providers/openfeature-flagd-provider"
  spec.metadata["changelog_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/issues"
  spec.metadata["documentation_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/README.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "grpc", "~> 1.50"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12.0"
  spec.add_development_dependency "standard", "~> 1.35.1"
end
