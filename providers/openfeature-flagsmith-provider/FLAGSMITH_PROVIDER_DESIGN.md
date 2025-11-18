# Flagsmith OpenFeature Provider - Design Document

**Created:** 2025-11-17
**Status:** Design Phase
**Target:** OpenFeature Ruby SDK integration with Flagsmith

---

## 1. Research Summary

### 1.1 Flagsmith Ruby SDK Details

**Gem Name:** `flagsmith`
**Latest Version:** v4.3.0 (as of December 2024)
**Ruby Version:** Requires Ruby 2.4+
**GitHub:** https://github.com/Flagsmith/flagsmith-ruby-client
**Documentation:** https://docs.flagsmith.com/clients/server-side

#### Installation
```ruby
gem install flagsmith
```

#### Basic Initialization
```ruby
require "flagsmith"
$flagsmith = Flagsmith::Client.new(
  environment_key: 'FLAGSMITH_SERVER_SIDE_ENVIRONMENT_KEY'
)
```

#### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `environment_key` | String | **Required** | Server-side authentication token |
| `api_url` | String | "https://edge.api.flagsmith.com/api/v1/" | Custom self-hosted endpoint |
| `enable_local_evaluation` | Boolean | false | Local vs. remote flag evaluation mode |
| `request_timeout_seconds` | Integer | 10 | Network request timeout |
| `environment_refresh_interval_seconds` | Integer | 60 | Polling interval in local mode |
| `enable_analytics` | Boolean | false | Send usage analytics to Flagsmith |
| `default_flag_handler` | Lambda | nil | Fallback for missing/failed flags |

#### Flag Evaluation Methods

**Environment-level (no user context):**
```ruby
flags = $flagsmith.get_environment_flags()
show_button = flags.is_feature_enabled('secret_button')
button_data = flags.get_feature_value('secret_button')
```

**Identity-specific (with user context):**
```ruby
identifier = 'user@example.com'
traits = {'car_type': 'sedan', 'age': 30}
flags = $flagsmith.get_identity_flags(identifier, **traits)
show_button = flags.is_feature_enabled('secret_button')
value = flags.get_feature_value('secret_button')
```

#### Evaluation Modes
- **Remote Evaluation** (default): Blocking HTTP requests per flag fetch
- **Local Evaluation**: Asynchronous polling (~60 sec intervals)
- **Offline Mode**: Requires custom `offline_handler`

#### Default Flag Handler Pattern
```ruby
$flagsmith = Flagsmith::Client.new(
  environment_key: '<KEY>',
  default_flag_handler: lambda { |feature_name|
    Flagsmith::Flags::DefaultFlag.new(
      enabled: false,
      value: {'colour': '#ababab'}.to_json
    )
  }
)
```

---

## 2. OpenFeature Provider Patterns (from repo analysis)

### 2.1 Required Provider Interface

All providers must implement:
```ruby
class Provider
  attr_reader :metadata  # Returns ProviderMetadata with name

  # Lifecycle (optional)
  def init
  def shutdown

  # Required evaluation methods
  def fetch_boolean_value(flag_key:, default_value:, evaluation_context: nil)
  def fetch_string_value(flag_key:, default_value:, evaluation_context: nil)
  def fetch_number_value(flag_key:, default_value:, evaluation_context: nil)
  def fetch_integer_value(flag_key:, default_value:, evaluation_context: nil)
  def fetch_float_value(flag_key:, default_value:, evaluation_context: nil)
  def fetch_object_value(flag_key:, default_value:, evaluation_context: nil)
end
```

### 2.2 Return Type: ResolutionDetails

All fetch_* methods must return:
```ruby
OpenFeature::SDK::Provider::ResolutionDetails.new(
  value: <evaluated_value>,           # The flag value
  reason: <Reason constant>,          # TARGETING_MATCH, DEFAULT, DISABLED, ERROR, etc.
  variant: "variant_key",             # Optional variant identifier
  flag_metadata: { ... },             # Optional metadata
  error_code: <ErrorCode constant>,   # If error occurred
  error_message: "Error details"      # If error occurred
)
```

#### OpenFeature Reason Constants
- `TARGETING_MATCH` - Flag evaluated with targeting rules
- `DEFAULT` - Default value used
- `DISABLED` - Feature is disabled
- `ERROR` - Error during evaluation
- `STATIC` - Static value

#### OpenFeature ErrorCode Constants
- `PROVIDER_NOT_READY`
- `FLAG_NOT_FOUND`
- `TYPE_MISMATCH`
- `PARSE_ERROR`
- `TARGETING_KEY_MISSING`
- `INVALID_CONTEXT`
- `GENERAL`

### 2.3 Configuration Patterns Used in Repo

**Pattern 1: Options Object** (Used by GO Feature Flag provider)
```ruby
class Options
  def initialize(endpoint:, headers: {}, ...)
    validate_endpoint(endpoint)
    @endpoint = endpoint
    @headers = headers
  end
end
```

**Pattern 2: Block-Based Configuration** (Used by flagd provider)
```ruby
OpenFeature::Flagd::Provider.configure do |config|
  config.host = "localhost"
  config.port = 8013
end
```

### 2.4 Error Handling Pattern

Create custom exception hierarchy:
```ruby
class FlagsmithError < StandardError
  attr_reader :error_code, :error_message

  def initialize(error_code, error_message)
    @error_code = error_code  # Maps to SDK::Provider::ErrorCode
    @error_message = error_message
    super(error_message)
  end
end

class FlagNotFoundError < FlagsmithError
class TypeMismatchError < FlagsmithError
class ConfigurationError < FlagsmithError
```

### 2.5 Type Validation Pattern

```ruby
def evaluate(flag_key:, default_value:, allowed_classes:, evaluation_context: nil)
  # ... evaluation logic ...

  unless allowed_classes.include?(value.class)
    return SDK::Provider::ResolutionDetails.new(
      value: default_value,
      error_code: SDK::Provider::ErrorCode::TYPE_MISMATCH,
      error_message: "flag type #{value.class} does not match allowed types #{allowed_classes}",
      reason: SDK::Provider::Reason::ERROR
    )
  end
end
```

---

## 3. Proposed Flagsmith Provider Architecture

### 3.1 Directory Structure

```
providers/openfeature-flagsmith-provider/
├── lib/
│   └── openfeature/
│       └── flagsmith/
│           ├── provider.rb              # Main provider class
│           ├── configuration.rb         # Configuration/options class
│           ├── error/
│           │   └── errors.rb           # Custom exception hierarchy
│           └── version.rb              # Version constant
├── spec/
│   ├── spec_helper.rb
│   ├── provider_spec.rb
│   ├── configuration_spec.rb
│   └── fixtures/                       # Mock responses
├── openfeature-flagsmith-provider.gemspec
├── README.md
├── CHANGELOG.md
├── Gemfile
└── Rakefile
```

### 3.2 Key Design Decisions

#### Configuration Strategy
**Chosen: Options Object Pattern**

Reasoning:
- Flagsmith has many configuration options (api_url, timeouts, evaluation mode, etc.)
- Options object provides clear validation
- Aligns with GO Feature Flag provider pattern (most similar use case)

```ruby
options = OpenFeature::Flagsmith::Configuration.new(
  environment_key: "your_key",
  api_url: "https://edge.api.flagsmith.com/api/v1/",
  enable_local_evaluation: false,
  request_timeout_seconds: 10,
  enable_analytics: false
)

provider = OpenFeature::Flagsmith::Provider.new(configuration: options)
```

#### Evaluation Context Mapping

OpenFeature EvaluationContext → Flagsmith Identity + Traits:
- `evaluation_context.targeting_key` → Flagsmith identity identifier
- All other `evaluation_context.fields` → Flagsmith traits

```ruby
def map_context_to_identity(evaluation_context)
  return [nil, {}] if evaluation_context.nil?

  identifier = evaluation_context.targeting_key
  traits = evaluation_context.fields.reject { |k, _v| k == :targeting_key }

  [identifier, traits]
end
```

#### Flag Type Mapping

| Flagsmith Type | OpenFeature Type | Notes |
|----------------|------------------|-------|
| Boolean enabled | `fetch_boolean_value` | Use `is_feature_enabled` |
| String value | `fetch_string_value` | Use `get_feature_value` |
| Numeric value | `fetch_number_value` | Parse and validate |
| JSON value | `fetch_object_value` | Parse JSON string |

#### Error Handling Strategy

1. **Flagsmith errors** → Map to OpenFeature ErrorCodes
2. **Network errors** → `PROVIDER_NOT_READY` or `GENERAL`
3. **Type mismatches** → `TYPE_MISMATCH`
4. **Missing flags** → Return default with `FLAG_NOT_FOUND`

#### Reason Mapping

| Flagsmith State | OpenFeature Reason |
|-----------------|-------------------|
| Flag evaluated with identity | `TARGETING_MATCH` |
| Flag evaluated at environment level | `STATIC` |
| Flag not found | `DEFAULT` |
| Flag disabled | `DISABLED` |
| Error occurred | `ERROR` |

---

## 4. Implementation Plan

### Phase 1: Core Structure
1. Create directory structure
2. Setup gemspec with dependencies
3. Create Configuration class with validation
4. Create Provider class skeleton with metadata

### Phase 2: Flag Evaluation
5. Implement `fetch_boolean_value` (simplest case)
6. Implement context → identity/traits mapping
7. Add error handling for boolean evaluation
8. Implement remaining fetch_* methods

### Phase 3: Advanced Features
9. Handle default_flag_handler integration
10. Support local evaluation mode
11. Add proper lifecycle management (init/shutdown)

### Phase 4: Testing & Documentation
12. Create RSpec test suite with mocked Flagsmith responses
13. Write comprehensive README
14. Add usage examples
15. Configure release automation

---

## 5. Open Questions & Decisions Needed

### 5.1 Design Decisions - RESOLVED ✅

1. **Evaluation Mode Preference**
   - ✅ **Default to remote evaluation** (simpler, no polling overhead)
   - Configurable via `enable_local_evaluation` option

2. **Analytics**
   - ✅ **Opt-in** (`enable_analytics: false` by default)

3. **Default Flag Handler**
   - ✅ **Use OpenFeature's default_value** (matches other providers)
   - Do NOT implement Flagsmith's `default_flag_handler`
   - Return `default_value` with appropriate error_code/reason on failures

4. **Targeting Key Requirement**
   - ✅ **Fall back to environment-level flags** if no targeting_key
   - Use `get_environment_flags()` when targeting_key is nil/empty
   - Use `get_identity_flags()` when targeting_key is present

5. **Version Compatibility**
   - ✅ **Target upcoming version** (will be released soon)
   - Update dependency when new version is available

### 5.2 Technical Considerations

**Type Detection Challenge:**
Flagsmith's `get_feature_value` returns values as strings/JSON. We need to:
- Parse JSON for objects
- Detect numeric types
- Handle type mismatches gracefully

**Variant Support:**
Flagsmith doesn't have explicit "variants" like some systems. Options:
- Use feature key as variant
- Leave variant nil
- Use enabled/disabled as variant

**Metadata:**
Flagsmith flags don't inherently have metadata beyond enabled/value. We could:
- Include trait data as flag_metadata
- Leave empty
- Add custom metadata extraction

---

## 6. Dependencies

### Runtime
- `openfeature-sdk` (~> 0.3.1)
- `flagsmith` (~> 4.3.0)

### Development
- `rake` (~> 13.0)
- `rspec` (~> 3.12.0)
- `webmock` (~> 3.0) - for mocking Flagsmith HTTP calls
- `standard` - Ruby linter
- `rubocop` - Code style
- `simplecov` - Test coverage

---

## 7. Next Steps

1. **User Decisions** - Get answers to open questions above
2. **Proof of Concept** - Build minimal provider with boolean support
3. **Validate Approach** - Test with real Flagsmith instance
4. **Expand** - Add remaining types and features
5. **Polish** - Tests, docs, release config

---

## 8. References

- OpenFeature Specification: https://openfeature.dev/specification/
- Flagsmith Docs: https://docs.flagsmith.com/clients/server-side
- Flagsmith Ruby Client: https://github.com/Flagsmith/flagsmith-ruby-client
- GO Feature Flag Provider (reference impl): `providers/openfeature-go-feature-flag-provider/`
- flagd Provider (reference impl): `providers/openfeature-flagd-provider/`
