# Flipper::Cassanity

A [Cassanity](https://github.com/jnunemaker/cassanity) adapter for [Flipper](https://github.com/jnunemaker/flipper).

## Usage

```ruby
require 'flipper/adapters/cassanity'

# setup client, keyspace, and column family
client = Cassanity::Client.new
keyspace = client.keyspace(:cassanity)
column_family = keyspace.column_family({
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

# just making sure these exist in cassandra
keyspace.recreate
column_family.create

# now the part that actually sets up this gem
adapter = Flipper::Adapters::Cassanity.new(column_family)

# :boom: you are good to go, flip away
flipper = Flipper.new(adapter)
```

## Installation

Add this line to your application's Gemfile:

    gem 'flipper-cassanity'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flipper-cassanity

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
