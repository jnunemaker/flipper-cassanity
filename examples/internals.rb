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

# Register a few groups.
Flipper.register(:admins) { |thing| thing.admin? }
Flipper.register(:early_access) { |thing| thing.early_access? }

# Create a user class that has flipper_id instance method.
User = Struct.new(:flipper_id)

flipper[:stats].enable
flipper[:stats].enable flipper.group(:admins)
flipper[:stats].enable flipper.group(:early_access)
flipper[:stats].enable User.new('25')
flipper[:stats].enable User.new('90')
flipper[:stats].enable User.new('180')
flipper[:stats].enable flipper.random(15)
flipper[:stats].enable flipper.actors(45)

flipper[:search].enable

puts 'all docs in collection'
pp column_family.select
# all docs in collection
# [{"_id"=>"stats",
#   "actors"=>["25", "90", "180"],
#   "boolean"=>"true",
#   "groups"=>["admins", "early_access"],
#   "percentage_of_actors"=>"45",
#   "percentage_of_random"=>"15"},
#  {"_id"=>"flipper_features", "features"=>["stats", "search"]},
#  {"_id"=>"search", "boolean"=>"true"}]
puts

puts 'flipper get of feature'
pp adapter.get(flipper[:stats])
# flipper get of feature
# {:boolean=>"true",
#  :groups=>#<Set: {"admins", "early_access"}>,
#  :actors=>#<Set: {"25", "90", "180"}>,
#  :percentage_of_actors=>"45",
#  :percentage_of_random=>"15"}
