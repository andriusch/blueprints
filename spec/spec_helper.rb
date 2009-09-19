require 'fileutils'
require 'activerecord'
begin
  require 'mysqlplus'
rescue LoadError
end

spec_dir = File.dirname(__FILE__)
Dir.chdir spec_dir

ActiveRecord::Base.logger = Logger.new(File.join(spec_dir, "..", "debug.log"))

databases = YAML::load(IO.read("db/database.yml"))
db_info = databases[ENV["DB"] || "test"]
ActiveRecord::Base.establish_connection(db_info)

require 'spec/autorun'
require '../lib/blueprints'
require 'db/fruit'
require 'db/tree'

Spec::Runner.configure do |config|
  config.enable_blueprints(:root => File.expand_path(File.join(spec_dir, '..')), :prebuild => :big_cherry)
end
