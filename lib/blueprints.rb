require 'active_support'
files = %w{
context buildable namespace root_namespace plan file_context helper errors
database_backends/abstract database_backends/active_record database_backends/none
}

files << if defined? Spec or $0 =~ /script.spec$/
  'extensions/rspec'
else
  'extensions/test_unit'
end
files.each {|f| require File.join(File.dirname(__FILE__), 'blueprints', f) }

module Blueprints
  PLAN_FILES = [nil, "spec", "test"].map do |dir|
    ["blueprint"].map do |file|
      path = File.join([dir, file].compact)
      ["#{path}.rb", File.join(path, "*.rb")]
    end
  end.flatten

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
    @@orm.start_transaction
  end

  # Rollbacks transaction returning everything to state before test. Should be called after every test case.
  def self.teardown
    @@orm.rollback_transaction
  end

  # Sets up configuration, clears database, runs scenarios that have to be prebuilt. Should be run before all test cases and before <tt>setup</tt>.
  # Accepts following options:
  # * <tt>:delete_policy</tt> - allows changing how tables in database should be cleared. By default simply uses delete statement. Supports :delete and :truncate options.
  # * <tt>:filename</tt> - Allows passing custom filename pattern in case blueprints are held in place other than spec/blueprint, test/blueprint, blueprint.
  # * <tt>:prebuild</tt> - Allows passing scenarios that should be prebuilt and available in all tests. Works similarly to fixtures.
  # * <tt>:root</tt> - Allows passing custom root folder to use in case of non rails and non merb project.
  # * <tt>:orm</tt> - Allows specifying what orm should be used. Default to <tt>:active_record</tt>, also allows <tt>:none</tt>
  def self.load(options = {})
    options.assert_valid_keys(:delete_policy, :filename, :prebuild, :root, :orm)
    options.symbolize_keys!
    return unless Namespace.root.empty?

    orm = (options.delete(:orm) || :active_record).to_sym
    raise ArgumentError, "Unsupported ORM #{orm}. Blueprints supports only #{supported_orms.join(', ')}" unless supported_orms.include?(orm)
    @@orm = DatabaseBackends.const_get(orm.to_s.classify).new
    @@orm.delete_tables(@@delete_policy = options[:delete_policy])

    @@framework_root = options[:root] if options[:root]
    load_scenarios_files(options[:filename] || PLAN_FILES)

    Namespace.root.prebuild(options[:prebuild])
  end

  # Clears all tables in database. Also accepts a list of tables in case not all tables should be cleared.
  def self.delete_tables(*tables)
    @@orm.delete_tables(@@delete_policy, *tables)
  end

  def self.warn(message, blueprint)
    $stderr.puts("**WARNING** #{message}: '#{blueprint}'")
  end

  protected

  # Loads blueprints file and creates blueprints from data it contains. Is run by setup method
  def self.load_scenarios_files(*patterns)
    FileContext.evaluating = true

    patterns.flatten!
    patterns.collect! {|pattern| File.join(framework_root, pattern)} if framework_root

    patterns.each do |pattern|
      unless (files = Dir.glob(pattern)).empty?
        files.each{|f| FileContext.module_eval File.read(f)}
        FileContext.evaluating = false
        return
      end
    end

    FileContext.evaluating = false
    raise "Plans file not found! Put plans in #{patterns.join(' or ')} or pass custom filename pattern with :filename option"
  end
end
