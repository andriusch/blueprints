module Blueprints
  # Namespace class, inherits from Buildable. Allows adding and finding child blueprints/namespaces and building
  # all it's children.
  class Namespace < Buildable
    cattr_accessor :root
    delegate :empty?, :size, :to => :@children

    # Creates namespace by name. See Buildable#new.
    # @param name (see Buildable#initialize)
    # @param context (see Buildable#initialize)
    def initialize(name, context)
      @children = Hash.new do |hash, search_key|
        pair = hash.detect do |name,|
          name.is_a?(Regexp) and search_key.to_s =~ name
        end
        hash[search_key] = BlueprintNameProxy.new(search_key, pair[1]) if pair
      end
      super(name, context)
    end

    # Adds child to namespaces children. Warns if this will overwrite existing child.
    # @param [Blueprints::Buildable] child Namespace or blueprint to add as a child.
    def add_child(child)
      Blueprints.warn("Overwriting existing blueprint", child) if @children[child.name]
      @children[child.name] = child
    end

    # Returns all direct children blueprints and namespaces of this namespace.
    # @return [Array<Blueprints::Buildable>] Array of direct children
    def children
      @children.values
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
    # @param [Object] environment Eval context that this namespace was built in.
    def demolish(environment)
      @children.each_value { |blueprint| blueprint.demolish(environment) }
    end

    protected

    def build_self(environment, options)
      children = Array(@children[:default] || @children.values)
      result(environment) { children.collect { |child| child.build(environment, options) } }
    end

    def update_context(options)
      @children.each_value { |child| child.update_context(options) }
      super
    end
  end
end
