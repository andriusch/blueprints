module Blueprints
  module Helper
    def build_plan(*names)
      Plan.build(*names)   
      Plan.copy_ivars(self)
    end

    alias :build :build_plan

    def demolish(*args)
      options = args.extract_options!
      Blueprints.delete_tables(*args)

      if options[:undo] == :all
        Plan.executed_plans.clear
      else
        undo = [options[:undo]].flatten.compact
        unless (not_found = undo - Plan.executed_plans.to_a).blank?
          raise(ArgumentError, "Scenario(s) #{not_found} not found")
        end
        Plan.executed_plans -= undo
      end
    end
  end
end