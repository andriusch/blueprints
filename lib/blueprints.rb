require 'active_support'
require 'active_support/core_ext'
require 'database_cleaner'
require 'set'

files = %w{
context buildable namespace root_namespace blueprint file_context helper errors
database_backends/abstract database_backends/active_record database_backends/none
}
files << if defined? Spec or $0 =~ /script.spec$/ or defined? RSpec
  'extensions/rspec'
else
  'extensions/test_unit'
end
files.each {|f| require File.join(File.dirname(__FILE__), 'blueprints', f) }

module Blueprints
  BLUEPRINT_FILES = [nil, "spec", "test"].map do |dir|
    ["blueprint"].map do |file|
      path = File.join([dir, file].compact)
      ["#{path}.rb", File.join(path, "*.rb")]
    end
  end.flatten
  mattr_reader :use_transactions, :prebuild

  # Returns a list of supported ORMs. For now it supports ActiveRecord and None.
  def self.supported_orms
    DatabaseBackends.constants.collect {|class_name| class_name.to_s.underscore.to_sym } - [:abstract]
  end

  # Returns root of project blueprints is used in. Automatically detected for rails and merb. Can be overwritten by using
  # <tt>:root</tt> options when loading blueprints. If root can't be determined, returns nil which means that current
  # directory is asumed as root.
  def self.framework_root
    @@framework_root ||= RAILS_ROOT rescue Rails.root rescue Merb.root rescue nil
  end

  # Setups variables from global context and starts transaction. Should be called before every test case.
  def self.setup(current_context)
    Namespace.root.setup
    Namespace.root.copy_ivars(current_context)
    DatabaseCleaner.start unless @@orm == :none
  end

  # Rollbacks transaction returning everything to state before test. Should be called after every test case.
  def self.teardown
    DatabaseCleaner.clean unless @@orm == :none
  end

  # Sets up configuration, clears database, runs scenarios that have to be prebuilt. Should be run before all test cases and before <tt>setup</tt>.
  # Accepts following options:
  # * <tt>:filename</tt> - Allows passing custom filename pattern in case blueprints are held in place other than spec/blueprint, test/blueprint, blueprint.
  # * <tt>:prebuild</tt> - Allows passing scenarios that should be prebuilt and available in all tests. Works similarly to fixtures.
  # * <tt>:root</tt> - Allows passing custom root folder to use in case of non rails and non merb project.
  # * <tt>:orm</tt> - Allows specifying what orm should be used. Default to <tt>:active_record</tt>, also allows <tt>:none</tt>
  # * <tt>:transactions</tt> - Allows to specify not to use transactions when it's needed.
  def self.load(options = {})
    options.symbolize_keys!
    options.reverse_merge!(:filename => BLUEPRINT_FILES, :orm => :active_record, :transactions => true)
    options.assert_valid_keys(:delete_policy, :filename, :prebuild, :root, :orm, :transactions)
    STDERR.puts "DEPRECATION WARNING: delete_policy is deprecated and truncation is now used by default" if options[:delete_policy]
    return unless Namespace.root.empty?

    @@orm = options.delete(:orm).to_sym
    raise ArgumentError, "Unsupported ORM #{@@orm}. Blueprints supports only #{supported_orms.join(', ')}" unless supported_orms.include?(@@orm)
    DatabaseBackends.const_get(@@orm.to_s.classify).new
    DatabaseCleaner.clean_with :truncation unless @@orm == :none

    @@framework_root = options[:root] if options[:root]
    load_scenarios_files(options[:filename])

    @@use_transactions = options[:transactions]
    DatabaseCleaner.strategy = (@@use_transactions ? :transaction : :truncation) unless @@orm == :none
    @@prebuild = options[:prebuild]
    Namespace.root.prebuild(@@prebuild) if @@use_transactions
  end

  def self.backtrace_cleaner
    @backtrace_cleaner ||= ActiveSupport::BacktraceCleaner.new.tap do |bc|
      root_sub = /^#{@@framework_root}[\\\/]/
      blueprints_path = File.dirname(__FILE__).sub(root_sub, '')

      bc.add_filter {|line| line.sub('(eval)', @@file) }
      bc.add_filter {|line| line.sub(root_sub, '') }

      bc.add_silencer {|line| File.dirname(line).starts_with?(blueprints_path) }
      bc.add_silencer {|line| Gem.path.any? {|path| File.dirname(line).starts_with?(path) } }
    end
  end

  def self.warn(message, blueprint)
    $stderr.puts("**WARNING** #{message}: '#{blueprint}'")
    $stderr.puts(backtrace_cleaner.clean(caller).first)
  end

  protected

  # Loads blueprints file and creates blueprints from data it contains. Is run by setup method
  def self.load_scenarios_files(*patterns)
    FileContext.evaluating = true

    patterns.flatten!
    patterns.collect! {|pattern| File.join(framework_root, pattern)} if framework_root

    patterns.each do |pattern|
      unless (files = Dir.glob(pattern)).empty?
        files.each do |f|
          @@file = f
          FileContext.module_eval File.read(f)
        end
        FileContext.evaluating = false
        return
      end
    end

    FileContext.evaluating = false
    raise "Blueprints file not found! Put blueprints in #{patterns.join(' or ')} or pass custom filename pattern with :filename option"
  end
end
