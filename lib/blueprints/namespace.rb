module Blueprints
  # Namespace class, inherits from Buildable. Allows adding and finding child blueprints/namespaces and building
  # all it's children.
  class Namespace < Buildable
    cattr_accessor :root
    attr_reader :children
    delegate :empty?, :size, :to => :@children

    # Creates namespace by name. See Buildable#new.
    # @param name (see Buildable#initialize)
    # @param context (see Buildable#initialize)
    def initialize(name, context)
      super(name, context)
      @children = {}
    end

    # Adds child to namespaces children. Warns if this will overwrite existing child.
    # @param [Blueprints::Buildable] child Namespace or blueprint to add as a child.
    def add_child(child)
      Blueprints.warn("Overwriting existing blueprint", child) if @children[child.name]
      @children[child.name] = child
    end

    # Finds child by relative name.
    # @param [String] path Path to child. Path parts should be joined with '.' symbol.
    # @return [Blueprints::Buildable] Blueprint or namespace that matches path.
    # @raise [BlueprintNotFoundError] If child can't be found.
    def [](path)
      child_name, path = path.to_s.split('.', 2)

      child = @children[child_name.to_sym] or raise BlueprintNotFoundError, child_name
      if path
        child[path]
      else
        child
      end
    end

    # Builds all children and sets an instance variable named by name of namespace with the results.
    # @param eval_context (see Buildable#build)
    # @param build_once (see Buildable#build)
    # @param options (see Buildable#build)
    # @return [Array] Results of all blueprints.
    def build_self(eval_context, build_once, options)
      result(eval_context) { @children.values.collect { |child| child.build(eval_context, build_once, options) }.uniq }
    end

    # Demolishes all child blueprints and namespaces.
    # @param [Blueprints::EvalContext] eval_context Eval context that this namespace was built in.
    def demolish(eval_context)
      @children.each_value { |blueprint| blueprint.demolish(eval_context) }
    end
  end
end
