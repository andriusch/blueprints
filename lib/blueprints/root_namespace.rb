module Blueprints
  class RootNamespace < Namespace
    attr_reader :context, :plans
    attr_accessor :executed_plans
    
    def initialize
      @executed_plans = Set.new
      @global_executed_plans = Set.new
      @global_context = Module.new

      super ''
    end

    def setup
      @context = YAML.load(@global_context)
      @executed_plans = @global_executed_plans.clone
    end

    def copy_ivars(to)
      @context.instance_variables.each do |iv|
        to.instance_variable_set(iv, @context.instance_variable_get(iv))
      end
    end

    def prebuild(plans)
      @context = @global_context
      @global_scenarios = build(*plans) if plans
      @global_executed_plans = @executed_plans
      @global_context = YAML.dump(@global_context)
    end

    def build(*names)
      names.map {|name| self[name].build}
    end

    def add_variable(name, value)
      name = "@#{name}" unless name.to_s[0, 1] == "@" 
      @context.instance_variable_set(name, value) unless @context.instance_variable_get(name)
    end

    @@root = RootNamespace.new
  end
end
