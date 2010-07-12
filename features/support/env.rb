require 'cucumber'
require 'active_record'
Root = File.expand_path(File.dirname(__FILE__) + '/../..')
require File.expand_path(Root + '/lib/blueprints')

ActiveRecord::Base.logger = Logger.new("debug.log")
databases = YAML::load_file(Root + "/spec/active_record/fixtures/database.yml")
db_info = databases[ENV["DB"] || "test"]
ActiveRecord::Base.establish_connection(db_info)
# Comment out the next two lines if you're not using RSpec's matchers (should / should_not) in your steps.
#require 'cucumber/rspec'

require Root + '/spec/active_record/fixtures/fruit'
require Root + '/spec/active_record/fixtures/tree'

Blueprints.enable do |config|
  config.root = Root + '/spec/active_record'
  config.prebuild = :big_cherry
end
