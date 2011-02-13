
module Blueprints
  # Defines a root namespace that is used when no other namespace is. Apart from functionality in namespace it also allows
  # building blueprints/namespaces by name. Is also used for copying instance variables between blueprints/contexts/global
  # context.
  class RootNamespace < Namespace
    # Lists of executed blueprints (to prevent executing twice). Cleared before each test.
    attr_reader :executed_blueprints
    # Context that blueprints/namespaces are built against. Reset before each test.
    attr_writer :eval_context

    # Initialized new root context.
    def initialize
      @executed_blueprints = @global_executed_blueprints = []
      @auto_iv_list = Set.new

      super '', Context.new
    end

    # Loads all instance variables from global context to current one.
    def setup(eval_context)
      (@executed_blueprints - @global_executed_blueprints).each(&:undo!)
      @executed_blueprints = @global_executed_blueprints.clone

      if Blueprints.config.transactions
        Marshal.load(@global_variables).each { |name, value| eval_context.instance_variable_set(name, value) }
      else
        build(Blueprints.config.prebuild, eval_context)
      end
    end

    # Sets up a context and executes prebuilt blueprints against it.
    # @param [Array<Symbol, String>] blueprints Names of blueprints that are prebuilt.
    def prebuild(blueprints)
      eval_context = Object.new
      eval_context.extend Blueprints::Helper
      build(blueprints, eval_context) if blueprints

      @global_executed_blueprints = @executed_blueprints
      @global_variables = Marshal.dump(eval_context.instance_variables.each_with_object({}) { |iv, hash| hash[iv] = eval_context.instance_variable_get(iv) })
    end

    # Builds blueprints that are passed against current context.
    # @param [Array<Symbol, String>] names List of blueprints/namespaces to build.
    # @param current_context Object to build blueprints against.
    # @param options (see Buildable#build)
    # @option options (see Buildable#build)
    # @return Result of last blueprint/namespace.
    def build(names, current_context, options = {})
      names = [names] unless names.is_a?(Array)
      result = names.inject(nil) do |result, member|
        if member.is_a?(Hash)
          member.map { |name, opts| self[name].build(current_context, options.merge(:options => opts)) }.last
        else
          self[member].build(current_context, options)
        end
      end

      result
    end

    @@root = RootNamespace.new
  end
end
