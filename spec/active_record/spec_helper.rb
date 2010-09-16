require 'fileutils'
require 'logger'
version = ENV['RAILS']
gem 'activerecord', "~> #{version}" if version
require 'active_record'

Root = Pathname.new(__FILE__).dirname.join('..', '..')
$: << Root.to_s

ActiveRecord::Base.logger = Logger.new("debug.log")

databases = YAML::load(Root.join("spec/active_record/fixtures/database.yml").read)
db_info = databases[ENV["DB"] || "test"]
ActiveRecord::Base.establish_connection(db_info)

config_class = if version.to_s[0, 1] == '2'
  require 'spec'
  Spec::Runner
else
  gem 'rspec', '>= 2.0.0.beta'
  require 'rspec'
  RSpec
end

require 'lib/blueprints'
require 'spec/active_record/fixtures/fruit'
require 'spec/active_record/fixtures/tree'

config_class.configure do |config|
  config.mock_with :mocha
end

Blueprints.enable do |config|
  config.root = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  config.filename = 'spec/active_record/blueprint.rb'
  config.prebuild = :big_cherry
  config.transactions = !ENV["NO_TRANSACTIONS"]
end
