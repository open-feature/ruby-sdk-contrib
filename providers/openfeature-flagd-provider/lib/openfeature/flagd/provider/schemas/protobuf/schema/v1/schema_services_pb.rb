# frozen_string_literal: true

# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: schemas/protobuf/schema/v1/schema.proto for package 'OpenFeature.FlagD.Provider.Grpc'

require "grpc"
require_relative "schema_pb"

module OpenFeature
  module FlagD
    module Provider
      module Grpc
        module Service
          # Service defines the exposed rpcs of flagd
          class Service
            include ::GRPC::GenericService

            self.marshal_class_method = :encode
            self.unmarshal_class_method = :decode
            self.service_name = "schema.v1.Service"

            rpc :ResolveAll, ::OpenFeature::FlagD::Provider::Grpc::ResolveAllRequest,
                ::OpenFeature::FlagD::Provider::Grpc::ResolveAllResponse
            rpc :ResolveBoolean, ::OpenFeature::FlagD::Provider::Grpc::ResolveBooleanRequest,
                ::OpenFeature::FlagD::Provider::Grpc::ResolveBooleanResponse
            rpc :ResolveString, ::OpenFeature::FlagD::Provider::Grpc::ResolveStringRequest,
                ::OpenFeature::FlagD::Provider::Grpc::ResolveStringResponse
            rpc :ResolveFloat, ::OpenFeature::FlagD::Provider::Grpc::ResolveFloatRequest,
                ::OpenFeature::FlagD::Provider::Grpc::ResolveFloatResponse
            rpc :ResolveInt, ::OpenFeature::FlagD::Provider::Grpc::ResolveIntRequest,
                ::OpenFeature::FlagD::Provider::Grpc::ResolveIntResponse
            rpc :ResolveObject, ::OpenFeature::FlagD::Provider::Grpc::ResolveObjectRequest,
                ::OpenFeature::FlagD::Provider::Grpc::ResolveObjectResponse
            rpc :EventStream, ::OpenFeature::FlagD::Provider::Grpc::EventStreamRequest,
                stream(::OpenFeature::FlagD::Provider::Grpc::EventStreamResponse)
          end

          Stub = Service.rpc_stub_class
        end
      end
    end
  end
end