require 'rubygems'
require 'fileutils'
require 'active_record'
begin
  require 'mysqlplus'
rescue LoadError
end

Dir.chdir File.join(File.dirname(__FILE__), '..', '..')

ActiveRecord::Base.logger = Logger.new("debug.log")

databases = YAML::load(IO.read("spec/active_record/fixtures/database.yml"))
db_info = databases[ENV["DB"] || "test"]
ActiveRecord::Base.establish_connection(db_info)

require 'spec/autorun'
require 'lib/blueprints'
require 'spec/active_record/fixtures/fruit'
require 'spec/active_record/fixtures/tree'

Spec::Runner.configure do |config|
  config.mock_with :mocha
  config.enable_blueprints :root => File.expand_path(File.join(File.dirname(__FILE__))), :prebuild => :big_cherry
end
