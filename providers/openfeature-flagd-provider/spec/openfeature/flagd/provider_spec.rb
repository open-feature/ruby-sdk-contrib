# frozen_string_literal: true

require "openfeature/flagd/provider/schema/v1/schema_services_pb"

RSpec.describe OpenFeature::FlagD::Provider do
  subject { Schema::V1::Service::Service.new }

  context 'resolve boolean' do

    it do
      
      subject.ResolveBoolean(fla)
    end
  end
end
