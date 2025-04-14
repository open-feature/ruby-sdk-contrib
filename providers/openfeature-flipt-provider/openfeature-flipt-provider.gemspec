# frozen_string_literal: true

require_relative "lib/openfeature/flipt/version"

Gem::Specification.new do |spec|
  spec.name = "openfeature-flipt-provider"
  spec.version = OpenFeature::Flipt::VERSION
  spec.authors = ["Firdaus Al Ghifari"]
  spec.email = ["firdaus.alghifari@gmail.com"]

  spec.summary = "OpenFeature Flipt Provider for Ruby"
  spec.description = "OpenFeature Flipt Provider for Ruby"
  spec.homepage = "https://github.com/open-feature/ruby-sdk-contrib/tree/main/providers/openfeature-flipt-provider"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/tree/main/providers/openfeature-flipt-provider"
  spec.metadata["changelog_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/blob/main/providers/openfeature-flipt-provider/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/issues"
  spec.metadata["documentation_uri"] = "https://github.com/open-feature/ruby-sdk-contrib/tree/main/providers/openfeature-flipt-provider/README.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ffi", "~> 1.17"
  spec.add_dependency "openfeature-sdk", "~> 0.4.0"
  spec.add_dependency "flipt_client", "~> 0.10.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12.0"
  spec.add_development_dependency "standard", ">= 1.35.1"
  spec.add_development_dependency "rubocop"
end
