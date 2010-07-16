module Blueprints
  # A helper module that should be included in test framework. Adds methods <tt>build</tt> and <tt>demolish</tt>
  module Helper
    # Builds one or more blueprints by their names. You can pass names as symbols or strings. You can also pass additional
    # options hash which will be available by calling <tt>options</tt> in blueprint block. Returns result of blueprint block.
    #   # build :apple and orange blueprints
    #   build :apple, :orange
    #
    #   # build :apple scenario with additional options
    #   build :apple => {:color => 'red'}
    #
    #   # options can also be passed for several blueprints
    #   build :pear, :apple => {:color => 'red'}, :orange => {:color => 'orange'}
    def build_blueprint(*names)
      Namespace.root.build(names, self, true)
    end

    # Same as #build_blueprint except that you can use it to build same blueprint several times.
    def build_blueprint!(*names)
      Namespace.root.build(names, self, false)
    end

    # Returns attributes that are used to build blueprint. To set what attributes are used you need to call attributes
    # method when defining blueprint like this:
    #   blueprint :apple do
    #     Fruit.build attributes
    #   end.attributes(:name => 'apple')
    def build_attributes(name)
      Namespace.root[name].build_parents
      Namespace.root[name].normalized_attributes.tap { Blueprints::Namespace.root.copy_ivars(self) }
    end

    alias :build :build_blueprint
    alias :build! :build_blueprint!

    # Clears all tables in database. You can pass table names to clear only those tables. You can also pass <tt>:undo</tt> option
    # to remove scenarios from built scenarios cache.
    #
    # TODO: add sample usage
    def demolish(*args)
      STDERR.puts "DEPRECATION WARNING: demolish is deprecated and will be changed to support per blueprint demolishing in blueprints 0.8.0"
      options = args.extract_options!
      args = (ActiveRecord::Base.connection.tables - ['schema_migrations']) if args.blank?
      args.each {|table| ActiveRecord::Base.connection.execute("DELETE FROM #{table}") }

      if options[:undo] == :all
        Namespace.root.executed_blueprints.clear
      else
        undo = [options[:undo]].flatten.compact.collect(&:to_s)
        unless (not_found = undo - Namespace.root.executed_blueprints.to_a).blank?
          raise(BlueprintNotFoundError, not_found)
        end
        Namespace.root.executed_blueprints -= undo
      end
    end
  end
end
