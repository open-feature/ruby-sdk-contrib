# frozen_string_literal: true

module StepHelpers
  def cast(type, value)
    case type
    when "Boolean" then value == "true"
    when "Integer" then value.to_i
    when "Float" then value.to_f
    else value
    end
  end
end
World(StepHelpers)

Given(/^an option "[^"]*" of type "[^"]*" with value "[^"]*"$/) do
  # no-op: caching/streaming options aren't applicable here
end

Given(/^a stable flagd provider$/) do
  @client = OpenFeature::Flagd::Provider.build_client
  @context = {}
end

Given(/^a (\w+)-flag with key "([^"]*)" and a default value "([^"]*)"$/) do |type, key, default|
  @type = type
  @key = key
  @default = default
end

Given(/^a context containing a key "([^"]*)", with type "([^"]*)" and with value "([^"]*)"$/) do |key, type, value|
  @context[key] = cast(type, value)
end

Given(/^a context containing a targeting key with value "([^"]*)"$/) do |value|
  # the provider maps the "targeting_key" field to flagd's targetingKey
  @context["targeting_key"] = value
end

Given(/^a context containing a nested property with outer key "([^"]*)" and inner key "([^"]*)", with value "([^"]*)"$/) do |outer, inner, value|
  (@context[outer] ||= {})[inner] = value
end

When(/^the flag was evaluated with details$/) do
  ctx = @context.empty? ? nil : OpenFeature::SDK::EvaluationContext.new(**@context.transform_keys(&:to_sym))

  @details =
    case @type
    when "Boolean" then @client.fetch_boolean_value(flag_key: @key, default_value: cast("Boolean", @default), evaluation_context: ctx)
    when "String" then @client.fetch_string_value(flag_key: @key, default_value: @default, evaluation_context: ctx)
    when "Integer" then @client.fetch_integer_value(flag_key: @key, default_value: @default.to_i, evaluation_context: ctx)
    when "Float" then @client.fetch_float_value(flag_key: @key, default_value: @default.to_f, evaluation_context: ctx)
    when "Object" then @client.fetch_object_value(flag_key: @key, default_value: {}, evaluation_context: ctx)
    else raise "unsupported flag type: #{@type}"
    end
end

Then(/^the resolved details value should be "([^"]*)"$/) do |value|
  expect(@details[:value]).to eq(cast(@type, value))
end

Then(/^the reason should be "([^"]*)"$/) do |reason|
  expect(@details[:reason]).to eq(reason)
end

Then(/^the error-code should be "([^"]*)"$/) do |code|
  if code.empty?
    expect(@details[:error_code]).to be_nil
  else
    expect(@details[:error_code]).to eq(code)
  end
end
