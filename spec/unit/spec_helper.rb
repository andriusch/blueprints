#require 'logger'
#require 'active_record'

Dir.chdir File.join(File.dirname(__FILE__), '..', '..')

#ActiveRecord::Base.logger = Logger.new("debug.log")

#databases = YAML::load(IO.read("spec/active_record/fixtures/database.yml"))
#db_info = databases[ENV["DB"] || "test"]
#ActiveRecord::Base.establish_connection(db_info)

require 'spec'
require 'lib/blueprints'

Spec::Runner.configure do |config|
  config.mock_with :mocha

  config.before do
    Blueprints::Namespace.root.instance_variable_set(:@context, Blueprints::Context.new)
    @mock = Mocha::Mockery.instance.unnamed_mock
  end

  config.after do
    Blueprints::Namespace.root.children.clear
  end
end
