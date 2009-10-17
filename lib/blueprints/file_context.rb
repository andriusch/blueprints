module Blueprints
  module FileContext
    def self.blueprint(plan, &block)
      Plan.new(plan, &block)
    end

    def self.namespace(name)
      old_namespace = Namespace.root
      namespace = Namespace.new(name)
      Namespace.root = namespace
      yield
      old_namespace.add_child(namespace)
      Namespace.root = old_namespace
    end
  end
end