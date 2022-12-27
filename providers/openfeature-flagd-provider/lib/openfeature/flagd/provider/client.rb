# frozen_string_literal: true

require_relative "schemas/protobuf/schema/v1/schema_services_pb"
require_relative "configuration"
require "pry"

module OpenFeature
  module FlagD
    module Provider
      # Represents the configuration object for the FlagD provider,
      # and <tt>Context</tt> are configured.
      # This class is not meant to be interacted with directly but instead through the <tt>OpenFeature::SDK.configure</tt>
      # method
      class Client
        attr_reader :metadata

        Metadata = Struct.new("Metadata", :name)
        ResolutionDetails = Struct.new("ResolutionDetails", :value, :variant, :reason, :error_code, :error_message)

        PROVIDER_NAME = "Flagd Provider"
        TYPE_RESOLVER_MAPPER = {
          boolean: OpenFeature::FlagD::Provider::Grpc::ResolveBooleanRequest,
          integer: OpenFeature::FlagD::Provider::Grpc::ResolveIntRequest,
          float: OpenFeature::FlagD::Provider::Grpc::ResolveFloatRequest,
          string: OpenFeature::FlagD::Provider::Grpc::ResolveStringRequest,
          object: OpenFeature::FlagD::Provider::Grpc::ResolveObjectRequest
        }.freeze

        def initialize(configuration: nil)
          @configuration = Configuration.default_config.merge(Configuration.environment_variables_config).merge(configuration)
          @metadata = Metadata.new(PROVIDER_NAME)
          @grpc_client = OpenFeature::FlagD::Provider::Grpc::Service::Stub.new("#{@configuration.host}:#{@configuration.port}",
                                                                               :this_channel_is_insecure)
        end

        TYPE_RESOLVER_MAPPER.each_pair do |type, resolver|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def resolve_#{type}_value(flag_key:, default_value:, context: nil)
              request = #{resolver}.new(flag_key: flag_key)
              response = @grpc_client.resolve_#{type}(request)
              ResolutionDetails.new(response.value, response.variant, response.reason).to_h
            rescue GRPC::NotFound => e
              ResolutionDetails.new(nil, nil, "ERROR", "FLAG_NOT_FOUND", "The flag could not be found.").to_h
            rescue GRPC::InvalidArgument => e
            end
          RUBY
        end
      end
    end
  end
end
