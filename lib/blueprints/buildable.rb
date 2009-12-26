module Blueprints
  class Buildable
    attr_reader :name
    attr_accessor :namespace

    def initialize(name)
      @name, parents = parse_name(name)
      depends_on(*parents)

      Namespace.root.add_child(self) if Namespace.root
    end

    # Defines blueprint dependencies. Used internally, but can be used externally too.
    def depends_on(*scenarios)
      @parents = (@parents || []) + scenarios.map{|s| s.to_sym}
    end

    # Builds dependencies of blueprint and then blueprint itself.
    def build(options = {})
      namespace = self
      namespace.build_parent_plans while namespace = namespace.namespace
      build_parent_plans
      Namespace.root.context.options = options
      build_plan.tap { Namespace.root.context.options = {} }
    end

    protected

    def path
      @path = (namespace.path + "_" unless namespace.nil? or namespace.path.empty?).to_s + @name.to_s
    end

    def build_parent_plans
      @parents.each do |p|
        parent = begin
          namespace[p]
        rescue PlanNotFoundError
          Namespace.root[p]
        end

        parent.build
      end
    end

    def parse_name(name)
      case name
        when Hash
          return name.keys.first.to_sym, [name.values.first].flatten.map{|sc| parse_name(sc).first}
        when Symbol, String
          name = name.to_sym unless name == ''
          return name, []
        else
          raise TypeError, "Pass plan names as strings or symbols only, cannot build plan #{name.inspect}"
      end
    end
  end
end
