# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the **OpenFeature Ruby SDK Contributions** monorepo. It contains community-contributed providers (and hooks) for the [OpenFeature Ruby SDK](https://github.com/open-feature/ruby-sdk). Each provider is an independent Ruby gem with its own gemspec, dependencies, and test suite.

## Repository Structure

```
providers/
  openfeature-flagd-provider/       # gRPC-based flagd provider
  openfeature-flagsmith-provider/    # Flagsmith provider
  openfeature-flipt-provider/       # Flipt provider
  openfeature-go-feature-flag-provider/  # GO Feature Flag provider
  openfeature-meta_provider/        # Meta provider (combines multiple providers)
shared_config/
  .rubocop.yml                      # Shared RuboCop config (standard + standard-performance)
```

Each provider is a self-contained gem under `providers/`. There is no top-level Gemfile or Rakefile — all commands must be run from within a specific provider directory.

## Common Commands

All commands are run from within a provider directory (e.g., `cd providers/openfeature-flagd-provider`).

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop

# Run lint + tests together (most providers)
bin/rake
# or: bundle exec rake

# Run a single test file
bundle exec rspec spec/path/to/file_spec.rb

# Run a single test by line number
bundle exec rspec spec/path/to/file_spec.rb:42
```

**Note:** The flagd provider requires a running flagd instance for integration tests: `docker compose up -d flagd` from its `docker/` directory.

## Architecture

Each provider implements the OpenFeature provider interface (`openfeature-sdk` gem) with these resolution methods:
- `resolve_boolean_value(flag_key:, default_value:, context:)`
- `resolve_integer_value(flag_key:, default_value:, context:)`
- `resolve_float_value(flag_key:, default_value:, context:)`
- `resolve_string_value(flag_key:, default_value:, context:)`
- `resolve_object_value(flag_key:, default_value:, context:)`

Provider code lives under `lib/openfeature/<provider_name>/` with a `provider.rb` entry point and `provider/` subdirectory for implementation details.

## Code Style

- Linting uses [Standard Ruby](https://github.com/standardrb/standard) with `standard-performance` plugin, configured via `shared_config/.rubocop.yml`
- Each provider's `.rubocop.yml` inherits from the shared config
- Ruby >= 3.4 required

## Conventions

- Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) — this is enforced by a PR title linter and drives Release Please automation
- Tests use RSpec with `--format documentation`
- The flagd provider uses gRPC with protobuf-generated code in `lib/openfeature/flagd/provider/flagd/` (excluded from RuboCop)
- The `schemas/` submodule in the flagd provider points to [flagd-schemas](https://github.com/open-feature/flagd-schemas)

## CI

GitHub Actions runs tests for each provider independently across Ruby 3.4 and 4.0. The workflow is defined in `.github/workflows/ruby.yml`.
