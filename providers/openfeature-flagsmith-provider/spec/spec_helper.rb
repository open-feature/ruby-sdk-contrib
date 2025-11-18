# frozen_string_literal: true

require "bundler/setup"
require "rspec"
require "open_feature/sdk"
require "webmock/rspec"
require "flagsmith"

# Require our provider files
require_relative "../lib/openfeature/flagsmith/version"
require_relative "../lib/openfeature/flagsmith/options"
require_relative "../lib/openfeature/flagsmith/error/errors"
require_relative "../lib/openfeature/flagsmith/provider"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end
