# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "openfeature/otel/hook"
require "open_feature/sdk"
require "opentelemetry-sdk"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!
  config.filter_run_when_matching :focus
end
