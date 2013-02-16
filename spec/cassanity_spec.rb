require 'helper'
require 'flipper/adapters/cassanity'
require 'flipper/spec/shared_adapter_specs'

describe Flipper::Adapters::Cassanity do
  let(:client) { Cassanity::Client.new }
  let(:keyspace) { client.keyspace(:cassanity) }
  let(:column_family) {
    keyspace.column_family({
      name: :flipper,
      schema: {
        primary_key: [:key, :field],
        columns: {
          key: :text,
          field: :text,
          value: :text,
        },
      },
    })
  }

  subject { described_class.new(column_family) }

  before do
    keyspace.recreate
    column_family.create
  end

  it_should_behave_like 'a flipper adapter'
end
