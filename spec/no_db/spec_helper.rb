Dir.chdir File.join(File.dirname(__FILE__), '..', '..')

require 'spec/autorun'
require 'lib/blueprints'
require 'spec/no_db/fixtures/fruit'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

Blueprints.enable do |config|
  config.root = File.expand_path(File.join(File.dirname(__FILE__)))
  config.prebuild = :big_cherry
  config.orm = nil
end
