# Flipper::Cassanity

A [Cassanity](https://github.com/jnunemaker/cassanity) adapter for [Flipper](https://github.com/jnunemaker/flipper).

## Usage

```ruby
# Assumes keyspace created and column family exists with this schema:
#   {
#     primary_key: [:key, :field],
#     columns: {
#       key: :text,
#       field: :text,
#       value: :text,
#     },
#   }

require 'flipper/adapters/cassanity'
column_family = Cassanity::Client.new[:cassanity][:flipper]
adapter = Flipper::Adapters::Cassanity.new(column_family)
flipper = Flipper.new(adapter)
# profit...
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
