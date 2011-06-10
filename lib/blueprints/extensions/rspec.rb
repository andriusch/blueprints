module Blueprints
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

    # Returns Blueprint::Dependency object that can be used to define dependencies on other blueprints.
    # @example Building :post blueprint with different user.
    #   build :post => {:user => d(:admin)}
    # @example Building :post blueprint by first building :user_profile with :name => 'John', then taking value of @profile and calling +user+ on it.
    #   build :post => {:user => d(:user_profile, :profile, :name => 'John').user}
    # @see Blueprints::Dependency#initialize Blueprints::Dependency for accepted arguments.
    # @return [Blueprints::Dependency] Dependency object that can be passed as option when building blueprint/namespace.
    def d(*args)
      Dependency.new(*args)
    end

    alias :build :build_blueprint
    alias :blueprint_dependency :d
    alias :build! :build_blueprint!
  end
end

config_class = defined?(RSpec) ? RSpec : Spec::Runner
config_class.configure do |config|
  config.include(Blueprints::Helper)
  config.extend(Blueprints::DescribeHelper)
  config.before do
    Blueprints.setup(self)
  end
  config.after do
    Blueprints.teardown
  end
end
