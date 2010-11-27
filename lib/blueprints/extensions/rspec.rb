module DescribeHelper
  # Creates new before filter that builds blueprints before each spec.
  # @param names (see Helper#build)
  def build_blueprint(*names)
    before { build_blueprint *names }
  end

  # Same as DescribeHelper#build_blueprint except that you can use it to build same blueprint several times.
  # @param names (see Helper#build)
  def build_blueprint!(*names)
    before { build_blueprint! *names }
  end

  alias :build :build_blueprint
  alias :build! :build_blueprint!
end

config_class = defined?(RSpec) ? RSpec : Spec::Runner
config_class.configure do |config|
  config.include(Blueprints::Helper)
  config.extend(DescribeHelper)
  config.before do
    Blueprints.setup(self)
  end
  config.after do
    Blueprints.teardown
  end
end
