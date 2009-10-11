Dir.chdir File.join(File.dirname(__FILE__), '..', '..')

require 'spec/autorun'
require 'lib/blueprints'
require 'spec/no_db/fixtures/fruit'

Spec::Runner.configure do |config|
  config.mock_with :mocha
  config.enable_blueprints :root => File.expand_path(File.join(File.dirname(__FILE__))), :prebuild => :big_cherry, :orm => :none
end
