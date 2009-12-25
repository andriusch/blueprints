module Blueprints
  # A helper module that should be included in test framework. Adds methods <tt>build</tt> and <tt>demolish</tt>
  module Helper
    # Builds one or more blueprints by their names. You can pass names as symbols or strings. You can also pass additional
    # options hash which will be available by calling <tt>options</tt> in blueprint block. Returns result of blueprint block.
    #   # build :apple and orange blueprints
    #   build :apple, :orange
    #
    #   # build :apple scenario with additional options
    #   build :apple, :color => 'red'
    def build_plan(*names)
      result = Namespace.root.build(*names).last
      Namespace.root.copy_ivars(self)
      result
    end

    alias :build :build_plan

    # Clears all tables in database. You can pass table names to clear only those tables. You can also pass <tt>:undo</tt> option
    # to remove scenarios from built scenarios cache.
    #
    # TODO: add sample usage
    def demolish(*args)
      options = args.extract_options!
      Blueprints.delete_tables(*args)

      if options[:undo] == :all
        Namespace.root.executed_plans.clear
      else
        undo = [options[:undo]].flatten.compact.collect {|bp| bp.to_s }
        unless (not_found = undo - Namespace.root.executed_plans.to_a).blank?
          raise(PlanNotFoundError, not_found)
        end
        Namespace.root.executed_plans -= undo
      end
    end
  end
end
