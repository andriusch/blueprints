config_class = defined?(RSpec) ? RSpec : Spec::Runner
config_class.configure do |config|
  config.include(Blueprints::Helper)
  config.before do
    Blueprints.setup(self)
  end
  config.after do
    Blueprints.teardown
  end
end
