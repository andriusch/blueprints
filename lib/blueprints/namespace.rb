module Blueprints
  class Namespace
    cattr_accessor :root
    attr_reader :name
    attr_accessor :namespace
    delegate :empty?, :size, :to => :@children

    def initialize(name = '')
      @name = name
      @children = {}
    end

    def add_child(child)
      #TODO: Raise error for duplicate children!
      @children[child.name] = child
      child.namespace = self
    end

    def [](path)
      child_name, path = path.to_s.split('.', 2)
      child = @children[child_name.to_sym] or raise PlanNotFoundError, child_name
      if path
        child[path]
      else
        child
      end
    end

    def build
      Namespace.root.add_variable(name, @children.collect {|p| p.last.build }.uniq)
    end
  end
end