module Blueprints
  class Namespace
    #include Enumerable
    cattr_accessor :root
    attr_reader :name
    delegate :empty?, :size, :to => :@children

    def initialize(name = '')
      @name = name
      @children = {}
    end

    def add_child(child)
      #TODO: Raise error for duplicate children!
      @children[child.name] = child
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
  end
end