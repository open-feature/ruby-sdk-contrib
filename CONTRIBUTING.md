# Contributing to OpenFeature Ruby SDK Contributions

Welcome! We're glad you're interested in contributing to the [OpenFeature](https://openfeature.dev/) Ruby SDK Contributions repository. This monorepo contains community-contributed providers (and hooks) for the [OpenFeature Ruby SDK](https://github.com/open-feature/ruby-sdk).

## Repository Structure

```
providers/
  openfeature-flagd-provider/              # gRPC-based flagd provider
  openfeature-flagsmith-provider/          # Flagsmith provider
  openfeature-flipt-provider/              # Flipt provider
  openfeature-go-feature-flag-provider/    # GO Feature Flag provider
  openfeature-meta_provider/               # Meta provider (combines multiple providers)
shared_config/
  .rubocop.yml                             # Shared RuboCop config
```

Each provider is an independent Ruby gem with its own gemspec, Gemfile, Rakefile, and test suite. There is no top-level Gemfile or Rakefile -- all commands must be run from within a specific provider directory.

Shared linting configuration lives in `shared_config/`, and each provider's `.rubocop.yml` inherits from it.

## Prerequisites

- **Ruby** >= 3.1
- **Bundler**
- **Docker** (only required for flagd provider integration tests)

## Development Workflow

All commands are run from within a provider directory:

```bash
cd providers/<provider-name>

# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop

# Run lint + tests together
bin/rake

# Run a single test file
bundle exec rspec spec/path/to/file_spec.rb

# Run a single test by line number
bundle exec rspec spec/path/to/file_spec.rb:42
```

## Flagd Provider Specifics

The flagd provider has additional setup requirements compared to other providers.

### Git Submodule for Protobuf Schemas

The `providers/openfeature-flagd-provider/schemas/` directory is a git submodule pointing to [flagd-schemas](https://github.com/open-feature/flagd-schemas). After cloning the repo, initialize it:

```bash
git submodule init
git submodule update
```

### Regenerating Protobuf Code

Generated protobuf files live in `lib/openfeature/flagd/provider/flagd/` and are excluded from RuboCop. Regenerating them requires `grpc_tools_ruby_protoc`.

### Running Integration Tests

The flagd provider requires a running flagd instance for integration tests:

```bash
cd providers/openfeature-flagd-provider/docker
docker compose up -d flagd
```

Then run tests as usual:

```bash
cd providers/openfeature-flagd-provider
bundle exec rspec
```

## Adding a New Provider

1. Create a new directory under `providers/` (e.g., `providers/openfeature-<name>-provider/`).

2. Include the following files at minimum:
   - `<name>.gemspec` -- gem specification
   - `Gemfile` -- dependencies (typically just `gemspec`)
   - `Rakefile` -- default task running lint + tests
   - `.rubocop.yml` -- inheriting from `../../shared_config/.rubocop.yml`
   - `.rspec` -- RSpec configuration (typically `--format documentation`)
   - `bin/rake` -- binstub for running the default rake task
   - `spec/` -- test directory with `spec_helper.rb`

3. Add a CI job in `.github/workflows/ruby.yml` following the pattern of existing providers.

4. Add the package to `release-please-config.json` with the appropriate `package-name`, `version-file`, and other settings.

5. Add the initial version entry in `.release-please-manifest.json`.

6. Add an entry in `.github/component_owners.yml` with the provider path and maintainer GitHub handles.

## Commit Convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

Format: `type(scope): description`

**Types:** `feat`, `fix`, `chore`, `docs`, `test`, `refactor`, `perf`, `build`, `deps`, `ci`, `style`, `revert`

**Scope** is typically the provider name, e.g., `flagd`, `flipt`, `go-feature-flag`.

Examples:

```
feat(flagd): add streaming evaluation support
fix(flipt): handle nil context gracefully
docs: add CONTRIBUTING.md
```

This convention is enforced by the PR title linter and drives Release Please automation for versioning and changelogs.

## Pull Request Process

1. Fork the repository and create a feature branch.
2. Make your changes in the relevant provider directory.
3. Ensure `bin/rake` passes (lint + tests) in the affected provider directory.
4. Open a pull request targeting the `main` branch.
5. Use a PR title that follows the Conventional Commits format (this is enforced by a linter).
6. Release Please will automatically handle versioning and changelog generation when your PR is merged.

## Code Style

This project uses [Standard Ruby](https://github.com/standardrb/standard) with the `standard-performance` plugin. The shared configuration is in `shared_config/.rubocop.yml`.

Run the linter from within a provider directory:

```bash
bundle exec rubocop
```

## License

By contributing, you agree that your contributions will be licensed under the [Apache 2.0 License](LICENSE).
