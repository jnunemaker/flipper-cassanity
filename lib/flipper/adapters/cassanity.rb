require 'flipper'
require 'cassanity'

module Flipper
  module Adapters
    class Cassanity
      include Flipper::Adapter

      # Private: The key that stores the set of known features.
      FeaturesKey = :flipper_features

      # Public: The name of the adapter.
      attr_reader :name

      # Private: The column family where the data is stored.
      attr_reader :column_family

      # Public: Initializes a Cassanity flipper adapter.
      #
      # column_family - The Cassanity::ColumnFamily that should store the info.
      def initialize(column_family)
        @column_family = column_family
        @name = :cassanity
      end

      # Public: Gets the values for all gates for a given feature.
      #
      # Returns a Hash of Flipper::Gate#key => value.
      def get(feature)
        result = {}
        doc = doc_for(feature)
        fields = doc.keys

        feature.gates.each do |gate|
          result[gate.key] = case gate.data_type
          when :boolean, :integer
            doc[gate.key.to_s]
          when :set
            fields_to_gate_value(fields, gate)
          else
            unsupported_data_type(gate.data_type)
          end
        end

        result
      end

      # Public: Enables a gate for a given thing.
      #
      # feature - The Flipper::Feature for the gate.
      # gate - The Flipper::Gate to disable.
      # thing - The Flipper::Type being disabled for the gate.
      #
      # Returns true.
      def enable(feature, gate, thing)
        case gate.data_type
        when :boolean, :integer
          update feature.key, gate.key, thing.value.to_s
        when :set
          update feature.key, to_field(gate, thing), thing.value.to_s
        else
          unsupported_data_type(gate.data_type)
        end

        true
      end

      # Public: Disables a gate for a given thing.
      #
      # feature - The Flipper::Feature for the gate.
      # gate - The Flipper::Gate to disable.
      # thing - The Flipper::Type being disabled for the gate.
      #
      # Returns true.
      def disable(feature, gate, thing)
        case gate.data_type
        when :boolean
          delete feature.key
        when :integer
          update feature.key, gate.key, thing.value.to_s
        when :set
          delete feature.key, to_field(gate, thing)
        else
          unsupported_data_type(gate.data_type)
        end

        true
      end

      # Public: Adds a feature to the set of known features.
      def add(feature)
        update FeaturesKey, feature.name, 1
        true
      end

      # Public: The set of known features.
      def features
        rows = select(FeaturesKey)
        rows.map { |row| row['field'] }.to_set
      end

      # Private
      def to_field(gate, thing)
        "#{gate.key}/#{thing.value}"
      end

      # Private: Select rows matching key and optionally field.
      #
      # Returns an Array of Hashes.
      def select(key, field = :skip)
        @column_family.select({
          select: [:field, :value],
          where: where(key, field),
        })
      end

      # Private: Update key/field combo to value.
      #
      # Returns nothing.
      def update(key, field, value)
        @column_family.update({
          set: {value: value},
          where: {key: key, field: field},
        })
      end

      # Private: Delete rows matching key and optionally field as well.
      #
      # Returns nothing.
      def delete(key, field = :skip)
        @column_family.delete({
          where: where(key, field),
        })
      end

      # Private: Given a key and field it returns appropriate where hash for
      # querying the column family.
      #
      # Returns a Hash to be used as criteria for a query.
      def where(key, field)
        where = {key: key}
        where[:field] = field unless field == :skip
        where
      end

      # Private: Gets a hash of fields => values for the given feature.
      #
      # Returns a Hash of fields => values.
      def doc_for(feature)
        field_value_pairs = select(feature.key).map { |row| row.values }
        Hash[*field_value_pairs.flatten]
      end

      # Private: Returns a set for a gate based on an array of fields/values.
      #
      # Returns a Set of the values enabled for the gate.
      def fields_to_gate_value(fields, gate)
        regex = /^#{Regexp.escape(gate.key)}\//
        keys = fields.grep(regex)
        values = keys.map { |key| key.split('/', 2).last }
        values.to_set
      end

      # Private: Raises error letting user know that data type is not
      # supported by this adapter.
      def unsupported_data_type(data_type)
        raise "#{data_type} is not supported by this adapter"
      end
    end
  end
end
