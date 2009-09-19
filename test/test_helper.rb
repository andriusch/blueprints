require 'rubygems'
require 'activerecord'
require 'test/unit'
require 'active_record/test_case'
require 'shoulda'
begin
  require 'mysqlplus'
rescue LoadError
end

Dir.chdir(File.join(File.dirname(__FILE__), '..'))

ActiveRecord::Base.logger = Logger.new("debug.log")

databases = YAML::load(IO.read("spec/db/database.yml"))
db_info = databases[ENV["DB"] || "test"]
ActiveRecord::Base.establish_connection(db_info)

require 'lib/blueprints'
require 'spec/db/fruit'
require 'spec/db/tree'

class ActiveSupport::TestCase
  enable_blueprints :root => File.join(File.dirname(__FILE__), '..'), :prebuild => :big_cherry
end