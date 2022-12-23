# frozen_string_literal: true

module OpenFeature
  module FlagD
    module Provider
      class Metadata
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def ==(other)
          other.name == @name
        end
      end

      attr_reader :metadata
    end
  end
end
