#require 'logger'
#require 'active_record'

Dir.chdir File.join(File.dirname(__FILE__), '..', '..')

#ActiveRecord::Base.logger = Logger.new("debug.log")

#databases = YAML::load(IO.read("spec/active_record/fixtures/database.yml"))
#db_info = databases[ENV["DB"] || "test"]
#ActiveRecord::Base.establish_connection(db_info)

require 'spec'
require 'lib/blueprints'
require File.dirname(__FILE__) + '/fixtures'

Spec::Runner.configure do |config|
  config.mock_with :mocha

  config.before do
    Blueprints::Namespace.root.instance_variable_set(:@context, Blueprints::Context.new)
  end

  config.after do
    Blueprints::Namespace.root.children.clear
    Blueprints::Namespace.root.executed_blueprints.clear
  end
end
