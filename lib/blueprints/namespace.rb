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
      @children = {}
      super(name, context)
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

    # Demolishes all child blueprints and namespaces.
    # @param [Blueprints::EvalContext] eval_context Eval context that this namespace was built in.
    def demolish(eval_context)
      @children.each_value { |blueprint| blueprint.demolish(eval_context) }
    end

    protected

    # If has children named :default then builds it, otherwise builds all children.
    # Sets an instance variable named by name of namespace with the results.
    # @param eval_context (see Buildable#build)
    # @param options (see Buildable#build)
    # @return [Array] Results of all blueprints.
    def build_self(eval_context, options)
      children = Array(@children[:default] || @children.values)
      result(eval_context) { children.collect { |child| child.build(eval_context, options) } }
    end

    def update_context(options)
      @children.each_value { |child| child.update_context(options) }
      super
    end
  end
end
