require 'active_support'
require 'active_support/core_ext/kernel/singleton_class'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/enumerable'
require 'database_cleaner'
require 'set'

files = %w{
configuration context buildable namespace root_namespace blueprint helper errors dependency extensions
}
files.each { |f| require "blueprints/#{f}" }

# Main namespace of blueprints. Contains methods for Blueprints setup.
module Blueprints
  # Contains current configuration of blueprints
  # @return [Blueprints::Configuration] Current configuration.
  def self.config
    @@config ||= Blueprints::Configuration.new
  end

  # Setups variables from global context and starts transaction. Should be called before every test case.
  # @param current_context Object to copy instance variables for prebuilt blueprints/namespaces.
  def self.setup(current_context)
    Namespace.root.setup(current_context)
    if_orm { DatabaseCleaner.start }
  end

  # Rollbacks transaction returning everything to state before test. Should be called after every test case.
  def self.teardown
    if_orm { DatabaseCleaner.clean }
  end

  # Enables blueprints support for RSpec or Test::Unit depending on whether (R)Spec is defined or not. Yields
  # Blueprints::Configuration object that you can use to configure blueprints.
  # @yield [config] Used to configure blueprints.
  # @yieldparam [Blueprints::Configuration] config Current blueprints configuration.
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

    if_orm do
      DatabaseCleaner.clean_with :truncation
      DatabaseCleaner.strategy = (config.transactions ? :transaction : :truncation)
    end
    load_scenarios_files(config.filename)

    Namespace.root.prebuild(config.prebuild) if config.transactions
  end

  # Returns backtrace cleaner that is used to extract lines from user application.
  # @return [ActiveSupport::BacktraceCleaner] Backtrace cleaner
  def self.backtrace_cleaner
    @backtrace_cleaner ||= ActiveSupport::BacktraceCleaner.new.tap do |bc|
      root_sub        = /^#{config.root}[\\\/]/
      blueprints_path = File.expand_path(File.dirname(__FILE__))

      bc.add_filter { |line| line.sub(root_sub, '') }
      bc.add_silencer { |line| [blueprints_path, *Gem.path].any? { |path| File.expand_path(File.dirname(line)).starts_with?(path) } }
    end
  end

  # Returns array of blueprints that have not been used until now.
  # @return [Array<String>] List of unused blueprints.
  def self.unused
    each_blueprint.select { |blueprint| blueprint.uses.zero? }.collect(&:full_name)
  end

  # Returns array of most used blueprints.
  # @param [Hash] options Options on what blueprints to return.
  # @option options [Integer] :count Max amount of most used blueprints to return.
  # @option options [Integer] :at_least Only blueprints that have at least specified number of uses will be returned.
  # @return [Array<Array<String, Integer>>] List of most used blueprints together with their use counts.
  def self.most_used(options = {})
    blueprints = each_blueprint.collect { |blueprint| [blueprint.full_name, blueprint.uses] }.sort { |a, b| b[1] <=> a[1] }
    blueprints = blueprints.take(options[:count]) if options[:count]
    blueprints.reject! { |blueprint| blueprint[1] < options[:at_least] } if options[:at_least]
    blueprints
  end

  # Warns a user (often about deprecated feature).
  # @param [String] message Message to output.
  # @param [Blueprints::Blueprint] blueprint Name of blueprint that this occurred in.
  def self.warn(message, blueprint)
    $stderr.puts("**WARNING** #{message}: '#{blueprint.name}'")
    $stderr.puts(backtrace_cleaner.clean(blueprint.backtrace(caller)).first)
  end

  protected

  # Loads blueprints file and creates blueprints from data it contains. Is run by setup method.
  # @param [Array<String>] patterns List of filesystem patterns to search blueprint files in.
  # @raise [RuntimeError] If no blueprints file can be found.
  def self.load_scenarios_files(patterns)
    patterns.each do |pattern|
      pattern = config.root.join(pattern)
      files   = Dir[pattern.to_s]
      files.each { |file| Context.eval_within_context(:file => file, :namespace => Namespace.root) }
      return if files.size > 0
    end

    raise "Blueprints file not found! Put blueprints in #{patterns.join(' or ')} or pass custom filename pattern with :filename option"
  end

  private

  def self.each_blueprint(from = Namespace.root)
    enumerator_class.new do |enum|
      from.children.values.collect do |child|
        if child.is_a?(Blueprints::Blueprint)
          enum.yield child
        else
          each_blueprint(child).each { |blueprint| enum.yield blueprint }
        end
      end
    end
  end

  def self.enumerator_class
    @enumerator_class ||= if defined?(Enumerator)
                            Enumerator
                          else
                            require 'generator'
                            Generator
                          end
  end

  def self.if_orm
    yield
  rescue DatabaseCleaner::NoORMDetected
  end
end
