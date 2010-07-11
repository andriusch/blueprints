require 'rubygems'
require 'fileutils'
require 'logger'
version = ENV['RAILS']
gem 'activerecord', version == '3' ? '>= 3.0.0.beta' : "~> #{version}" if version
require 'active_record'

Dir.chdir File.join(File.dirname(__FILE__), '..', '..')

ActiveRecord::Base.logger = Logger.new("debug.log")

databases = YAML::load(IO.read("spec/active_record/fixtures/database.yml"))
db_info = databases[ENV["DB"] || "test"]
ActiveRecord::Base.establish_connection(db_info)

config_class = if version.to_s[0, 1] == '3'
  gem 'rspec', '>= 2.0.0.beta'
  require 'rspec'
  RSpec
else
  require 'spec'
  Spec::Runner
end

require 'lib/blueprints'
require 'spec/active_record/fixtures/fruit'
require 'spec/active_record/fixtures/tree'

config_class.configure do |config|
  config.mock_with :mocha
  config.enable_blueprints :root => File.expand_path(File.join(File.dirname(__FILE__))), :prebuild => :big_cherry, :transactions => !ENV["NO_TRANSACTIONS"]
end
