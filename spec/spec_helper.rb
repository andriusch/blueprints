@orm, @version = (ENV['ORM'] || 'active_record').split('.', 2)
gem_mappings = {'active_record' => 'activerecord'}
gem gem_mappings[@orm], "~> #{@version}" if @version
require @orm unless @orm == 'none'

Root = Pathname.new(__FILE__).dirname.join('..')
$: << Root.to_s

require 'logger'
@logger_file = Root.join('debug.log')
@logger = Logger.new(@logger_file)

require 'lib/blueprints'
require "spec/support/#{@orm}/initializer"

config_class = if @rspec1
  gem 'rspec', '~> 1.0'
  require 'spec'
  Spec::Runner
else
  gem 'rspec', '>= 2.0.0.beta'
  require 'rspec'
  RSpec
end

config_class.configure do |config|
  config.mock_with :mocha
end

Blueprints.enable do |config|
  config.root = Root.join('spec')
  config.prebuild = :big_cherry
  config.transactions = @transactions
end
