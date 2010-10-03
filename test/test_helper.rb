require 'rubygems'
require 'logger'
require 'active_record'
require 'test/unit'
require 'active_record/test_case'
require 'shoulda'
require 'mocha'

Root = Pathname.new(__FILE__).dirname.join('..')
$: << Root.to_s

require 'lib/blueprints'
require "spec/support/active_record/initializer"

class ActiveSupport::TestCase
  def assert_similar(array1, array2)
    assert (array1 - array2).empty?, "Extra elements #{array1 - array2}"
    assert (array2 - array1).empty?, "Missing elements #{array2 - array1}"
  end
end

Blueprints.enable do |config|
  config.root = Root.join('spec')
  config.prebuild = :big_cherry
end
