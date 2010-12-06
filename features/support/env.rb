require 'cucumber'
require 'active_record'
require 'pathname'
Root = Pathname.new(__FILE__).dirname.join('..', '..')
$: << Root.join('lib').to_s

require 'blueprints'
require File.dirname(__FILE__) + "/../../spec/support/active_record/initializer"

# Comment out the next two lines if you're not using RSpec's matchers (should / should_not) in your steps.
#require 'cucumber/rspec'

Blueprints.enable do |config|
  config.root = Root.join('spec')
  config.prebuild = :big_cherry
end
