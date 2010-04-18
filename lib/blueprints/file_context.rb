module Blueprints
  # Module that blueprints file is executed against. Defined <tt>blueprint</tt> and <tt>namespace</tt> methods.
  module FileContext
    # Creates a new plan by name and block passed
    def self.blueprint(plan, &block)
      Plan.new(plan, &block)
    end

    # Creates new namespace by name, and evaluates block against it.
    def self.namespace(name)
      old_namespace = Namespace.root
      namespace = Namespace.new(name)
      Namespace.root = namespace
      yield
      old_namespace.add_child(namespace)
      Namespace.root = old_namespace
    end

    def self.d(name)
      Buildable::Dependency.new(name)
    end
  end
end
