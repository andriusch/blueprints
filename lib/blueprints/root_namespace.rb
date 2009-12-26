module Blueprints
  # Defines a root namespace that is used when no other namespace is. Apart from functionality in namespace it also allows
  # building blueprints/namespaces by name. Is also used for copying instance variables between blueprints/contexts/global
  # context.
  class RootNamespace < Namespace
    attr_reader :context, :plans
    attr_accessor :executed_plans

    def initialize
      @executed_plans = Set.new
      @global_executed_plans = Set.new

      super ''
    end

    # Loads all instance variables from global context to current one.
    def setup
      @context = Blueprints::Context.new
      YAML.load(@global_variables).each { |name, value| @context.instance_variable_set(name, value) }
      @executed_plans = @global_executed_plans.clone
    end

    # Copies all instance variables from current context to another one.
    def copy_ivars(to)
      @context.instance_variables.each do |iv|
        to.instance_variable_set(iv, @context.instance_variable_get(iv))
      end
    end

    # Sets up global context and executes prebuilt blueprints against it.
    def prebuild(plans)
      @context = Blueprints::Context.new
      @global_scenarios = build(*plans) if plans
      @global_executed_plans = @executed_plans

      @global_variables = YAML.dump(@context.instance_variables.each_with_object({}) {|iv, hash| hash[iv] = @context.instance_variable_get(iv) })
    end

    # Builds blueprints that are passed against current context.
    def build(*names)
      options = names.extract_options!
      names.map {|name| self[name].build(options) }
    end

    # Sets instance variable in current context to passed value.
    def add_variable(name, value)
      name = "@#{name}" unless name.to_s[0, 1] == "@"
      @context.instance_variable_set(name, value) unless @context.instance_variable_get(name)
    end

    @@root = RootNamespace.new
  end
end
