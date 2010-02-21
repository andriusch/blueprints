require 'rubygems'
require 'active_record'
require 'test/unit'
require 'active_record/test_case'
require 'shoulda'
require 'mocha'
begin
  require 'mysqlplus'
rescue LoadError
end

Dir.chdir(File.join(File.dirname(__FILE__), '..'))

ActiveRecord::Base.logger = Logger.new("debug.log")

databases = YAML::load(IO.read("spec/active_record/fixtures/database.yml"))
db_info = databases[ENV["DB"] || "test"]
ActiveRecord::Base.establish_connection(db_info)

require 'lib/blueprints'
require 'spec/active_record/fixtures/fruit'
require 'spec/active_record/fixtures/tree'

class ActiveSupport::TestCase
  enable_blueprints :root => File.join(File.dirname(__FILE__), '..'), :prebuild => :big_cherry, :filename => 'spec/active_record/blueprint.rb'

  def assert_similar(array1, array2)
    assert (array1 - array2).empty?, "Extra elements #{array1 - array2}"
    assert (array2 - array1).empty?, "Missing elements #{array2 - array1}"
  end
end
