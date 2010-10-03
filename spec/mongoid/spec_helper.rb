$: << File.join(File.dirname(__FILE__), '..', '..')

require 'mongoid'
require 'rspec'
require 'lib/blueprints'
require 'spec/mongoid/fixtures/fruit'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("blueprints")
  config.persist_in_safe_mode = false
end

RSpec.configure do |config|
  config.mock_with :mocha
end

Blueprints.enable do |config|
  config.root = File.expand_path(File.join(File.dirname(__FILE__)))
  config.prebuild = :big_cherry
  config.transactions = false
end
