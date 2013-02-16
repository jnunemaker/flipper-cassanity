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

        rows = @column_family.select({
          where: {
            key: feature.key,
          },
        })

        feature.gates.each do |gate|
          result[gate.key] = case gate.data_type
          when :boolean, :integer
            if gate_row = rows.detect { |row| row['field'] == gate.key.to_s }
              gate_row['value']
            end
          when :set
            regex = /^#{Regexp.escape(gate.key)}\//

            gate_rows = rows.select { |row| row['field'] =~ regex }
            gate_keys = gate_rows.map { |row| row['field'] }
            gate_values = gate_keys.map { |key| key.split('/', 2).last }
            gate_values.to_set
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
              key: feature.key,
              field: gate.key,
            },
          })
        when :set
          @column_family.update({
            set: {
              value: 1,
            },
            where: {
              key: feature.key,
              field: "#{gate.key}/#{thing.value}",
            },
          })
        else
          unsupported_data_type(gate.data_type)
        end

        true
      end

      # Public
      def disable(feature, gate, thing)
        case gate.data_type
        when :boolean
          @column_family.delete({
            where: {
              key: feature.key,
            },
          })
        when :integer
          @column_family.update({
            set: {
              value: thing.value.to_s,
            },
            where: {
              key: feature.key,
              field: gate.key,
            },
          })
        when :set
          @column_family.delete({
            where: {
              key: feature.key,
              field: "#{gate.key}/#{thing.value}"
            },
          })
        else
          unsupported_data_type(gate.data_type)
        end

        true
      end

      # Public: Adds a feature to the set of known features.
      def add(feature)
        @column_family.update({
          set: {
            value: 1,
          },
          where: {
            key: FeaturesKey,
            field: feature.name,
          },
        })
        true
      end

      # Public: The set of known features.
      def features
        rows = @column_family.select(where: {key: FeaturesKey.to_s})
        rows.map { |row| row['field'] }.to_set
      end

      # Private
      def unsupported_data_type(data_type)
        raise "#{data_type} is not supported by this adapter"
      end
    end
  end
end
