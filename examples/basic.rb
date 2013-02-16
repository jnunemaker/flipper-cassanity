# Nothing to see here... move along.
# Sets up load path for examples and requires some stuff
require 'pp'
require 'pathname'
require 'logger'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)

require 'flipper/adapters/cassanity'
require 'cassanity/instrumentation/log_subscriber'
Cassanity::Instrumentation::LogSubscriber.logger = Logger.new(STDOUT, Logger::DEBUG)

client = Cassanity::Client.new('127.0.0.1:9160', {
  instrumenter: ActiveSupport::Notifications,
})
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

keyspace.recreate
column_family.create

adapter = Flipper::Adapters::Cassanity.new(column_family)
flipper = Flipper.new(adapter)

flipper[:stats].enable

if flipper[:stats].enabled?
  puts "\n\nEnabled!\n\n\n"
else
  puts "\n\nDisabled!\n\n\n"
end

flipper[:stats].disable

if flipper[:stats].enabled?
  puts "\n\nEnabled!\n\n\n"
else
  puts "\n\nDisabled!\n\n\n"
end
