require File.join(File.dirname(__FILE__), 'blueprints/plan')
require File.join(File.dirname(__FILE__), 'blueprints/file_context')
require File.join(File.dirname(__FILE__), 'blueprints/helper')
require File.join(File.dirname(__FILE__), 'blueprints/errors')
if defined? Spec
  require File.join(File.dirname(__FILE__), 'blueprints/rspec_extensions')
else
  require File.join(File.dirname(__FILE__), 'blueprints/test_unit_extensions')
end

module Blueprints
  PLAN_FILES = [nil, "spec", "test"].map do |dir|
    ["blueprint", "blueprints"].map do |file|
      path = File.join([dir, file].compact)
      ["#{path}.rb", File.join(path, "*.rb")]
    end
  end.flatten

  DELETE_POLICIES = {:delete => "DELETE FROM %s", :truncate => "TRUNCATE %s"}

  def self.framework_root
    @@framework_root ||= RAILS_ROOT rescue Rails.root rescue Merb.root rescue nil
  end

  def self.setup(current_context)
    Plan.setup
    Plan.copy_ivars(current_context, true)
    ActiveRecord::Base.connection.increment_open_transactions
    ActiveRecord::Base.connection.transaction_joinable = false
    ActiveRecord::Base.connection.begin_db_transaction
  end

  def self.teardown
    ActiveRecord::Base.connection.rollback_db_transaction
    ActiveRecord::Base.connection.decrement_open_transactions
  end

  def self.load(options = {})
    return unless Plan.plans.empty?

    @@delete_sql = DELETE_POLICIES[options[:delete_policy]] || DELETE_POLICIES[:delete]                              
    delete_tables
    @@framework_root = options[:root] if options[:root]
    load_scenarios_files(options[:filename] || PLAN_FILES)

    Plan.prebuild(options[:prebuild])
  end

  def self.load_scenarios_files(*patterns)
    patterns.flatten!
    patterns.collect! {|pattern| File.join(framework_root, pattern)} if framework_root
    
    patterns.each do |pattern|
      unless (files = Dir.glob(pattern)).empty?
        files.each{|f| FileContext.module_eval File.read(f)}
        return
      end
    end
    
    raise "Plans file not found! Put plans in #{patterns.join(' or ')} or pass custom filename pattern with :filename option"
  end
  
  def self.delete_tables(*args)
    args = tables if args.blank?
    args.each { |t| ActiveRecord::Base.connection.delete(@@delete_sql % t)  }
  end

  def self.tables
    ActiveRecord::Base.connection.tables - skip_tables
  end

  def self.skip_tables
    %w( schema_info schema_migrations )
  end
end
