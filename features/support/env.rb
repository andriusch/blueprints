require 'cucumber'
require 'active_record'
require 'pathname'
Root = Pathname.new(__FILE__).dirname.join('..', '..')
$: << Root.to_s

require 'lib/blueprints'
require "spec/support/active_record/initializer"

# Comment out the next two lines if you're not using RSpec's matchers (should / should_not) in your steps.
#require 'cucumber/rspec'

Blueprints.enable do |config|
  config.root = Root.join('spec')
  config.prebuild = :big_cherry
end
