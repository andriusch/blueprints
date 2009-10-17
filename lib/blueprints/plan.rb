module Blueprints
  class Plan
    attr_reader :name
    attr_accessor :namespace

    def initialize(*scenario, &block)
      @name, parents = parse_name(*scenario)
      depends_on(*parents)
      @block = block

      Namespace.root.add_child(self)
    end

    def build
      build_parent_plans(Namespace.root.context)
      build_plan(Namespace.root.context)
    end

    def depends_on(*scenarios)
      @parents = (@parents || []) + scenarios.map{|s| s.to_sym}
    end

    protected

    def parse_name(name)
      case name
        when Hash
          return name.keys.first.to_sym, [name.values.first].flatten.map{|sc| parse_name(sc).first}
        when Symbol, String
          return name.to_sym, []
        else
          raise TypeError, "Pass plan names as strings or symbols only, cannot build plan #{name.inspect}"
      end
    end

    def say(*messages)
      puts messages.map { |message| "=> #{message}" }
    end

    def build_plan(context)
      surface_errors do
        if @block
          result = context.module_eval(&@block)
          iv_name = :"@#{@name}"
          context.instance_variable_set(iv_name, result) unless context.instance_variable_get(iv_name)
        end
      end unless Namespace.root.executed_plans.include?(@name)
      Namespace.root.executed_plans << @name
    end

    def build_parent_plans(context)
      @parents.each do |p|
        parent = begin
          namespace[p]
        rescue PlanNotFoundError
          Namespace.root[p]
        end

        parent.build_parent_plans(context)
        parent.build_plan(context)
      end
    end

    def surface_errors
      yield
    rescue StandardError => error
      puts
      say "There was an error building scenario '#{@name}'", error.inspect
      puts
      puts error.backtrace
      puts
      raise error
    end
  end
end