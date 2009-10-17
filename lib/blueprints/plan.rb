module Blueprints
  class Plan < Buildable
    def initialize(name, &block)
      super(name)
      @block = block
    end

    def build
      build_parent_plans
      build_plan
    end

    protected
    
    def build_plan
      surface_errors do
        if @block
          @result = Namespace.root.context.module_eval(&@block)
          Namespace.root.add_variable(@name, @result)
        end
      end unless Namespace.root.executed_plans.include?(@name)
      Namespace.root.executed_plans << @name
      @result
    end

    def build_parent_plans
      @parents.each do |p|
        parent = begin
          namespace[p]
        rescue PlanNotFoundError
          Namespace.root[p]
        end

        parent.build_parent_plans
        parent.build_plan
      end
    end

    def surface_errors
      yield
    rescue StandardError => error
      puts "\n=> There was an error building scenario '#{@name}'", error.inspect, '', error.backtrace
      raise error
    end
  end
end