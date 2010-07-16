require 'active_support'
require 'active_support/core_ext'
require 'database_cleaner'
require 'set'

files = %w{
configuration context buildable namespace root_namespace blueprint file_context helper errors extensions/deprecated
}
files.each {|f| require File.join(File.dirname(__FILE__), 'blueprints', f) }

module Blueprints
  # Contains current configuration of blueprints
  def self.config
    @@config ||= Blueprints::Configuration.new
  end

  # Setups variables from global context and starts transaction. Should be called before every test case.
  def self.setup(current_context)
    Namespace.root.setup
    Namespace.root.copy_ivars(current_context)
    DatabaseCleaner.start if config.orm
  end

  # Rollbacks transaction returning everything to state before test. Should be called after every test case.
  def self.teardown
    DatabaseCleaner.clean if config.orm
  end

  # Enables blueprints support for RSpec or Test::Unit depending on whether (R)Spec is defined or not. Yields
  # Blueprints::Configuration object that you can use to configure blueprints.
  def self.enable
    yield config if block_given?
    load
    extension = if defined? Cucumber
                  'cucumber'
                elsif defined? Spec or defined? RSpec
                  'rspec'
                else
                   'test_unit'
                end
    require File.join(File.dirname(__FILE__), 'blueprints', 'extensions', extension)
  end

  # Sets up configuration, clears database, runs scenarios that have to be prebuilt. Should be run before all test cases and before Blueprints#setup.
  def self.load
    return unless Namespace.root.empty?

    require File.join(File.dirname(__FILE__), 'blueprints', 'database_backends', config.orm.to_s) if config.orm
    DatabaseCleaner.clean_with :truncation if config.orm

    load_scenarios_files(config.filename)

    DatabaseCleaner.strategy = (config.transactions ? :transaction : :truncation) if config.orm
    Namespace.root.prebuild(config.prebuild) if config.transactions
  end

  def self.backtrace_cleaner
    @backtrace_cleaner ||= ActiveSupport::BacktraceCleaner.new.tap do |bc|
      root_sub = /^#{config.root}[\\\/]/
      blueprints_path = File.dirname(__FILE__).sub(root_sub, '')

      bc.add_filter {|line| line.sub(root_sub, '') }

      bc.add_silencer {|line| File.dirname(line).starts_with?(blueprints_path) }
      bc.add_silencer {|line| Gem.path.any? {|path| File.dirname(line).starts_with?(path) } }
    end
  end

  def self.warn(message, blueprint)
    $stderr.puts("**WARNING** #{message}: '#{blueprint.name}'")
    $stderr.puts(backtrace_cleaner.clean(blueprint.backtrace(caller)).first)
  end

  protected

  # Loads blueprints file and creates blueprints from data it contains. Is run by setup method
  def self.load_scenarios_files(patterns)
    patterns.each do |pattern|
      pattern = config.root.join(pattern)
      Dir[pattern].each {|f| FileContext.new f }
      return if Dir[pattern].size > 0
    end

    raise "Blueprints file not found! Put blueprints in #{patterns.join(' or ')} or pass custom filename pattern with :filename option"
  end
end
