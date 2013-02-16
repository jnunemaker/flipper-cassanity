require 'flipper'
require 'cassanity'

module Flipper
  module Adapters
    class Cassanity
      FeaturesKey = :flipper_features

      attr_reader :name

      def initialize(column_family)
        @column_family = column_family
        @name = :cassanity
      end

      # Public
      def get(feature)
        result = {}

        feature.gates.each do |gate|
          result[gate.key] = case gate.data_type
          when :boolean, :integer

          when :set
            Set.new
          else
            unsupported_data_type(gate.data_type)
          end
        end

        result
      end

      # Public
      def enable(feature, gate, thing)
        case gate.data_type
        when :boolean, :integer
          @column_family.update({
            set: {
              value: thing.value.to_s,
            },
            where: {
              feature: feature.key.to_s,
              gate: gate.key.to_s,
            },
          })
        when :set

        else
          unsupported_data_type(gate.data_type)
        end

        true
      end

      # Public
      def disable(feature, gate, thing)
        case gate.data_type
        when :boolean

        when :integer

        when :set

        else
          unsupported_data_type(gate.data_type)
        end

        true
      end

      # Public: Adds a feature to the set of known features.
      def add(feature)

        true
      end

      # Public: The set of known features.
      def features

      end

      # Private
      def unsupported_data_type(data_type)
        raise "#{data_type} is not supported by this adapter"
      end
    end
  end
end
