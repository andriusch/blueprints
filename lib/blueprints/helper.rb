module Blueprints
  module Helper
    def build_plan(*names)
      Namespace.root.build(*names)
      Namespace.root.copy_ivars(self)
    end

    alias :build :build_plan

    def demolish(*args)
      options = args.extract_options!
      Blueprints.delete_tables(*args)

      if options[:undo] == :all
        Namespace.root.executed_plans.clear
      else
        undo = [options[:undo]].flatten.compact
        unless (not_found = undo - Namespace.root.executed_plans.to_a).blank?
          raise(PlanNotFoundError, not_found)
        end
        Namespace.root.executed_plans -= undo
      end
    end
  end
end