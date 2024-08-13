# frozen_string_literal: true

require "bundler/setup"
require "rspec"
require "openfeature/go-feature-flag/go_feature_flag_provider"
require "openfeature/go-feature-flag/options"
require "openfeature/go-feature-flag/goff_api"
require "open_feature/sdk"
require "webmock/rspec"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end
