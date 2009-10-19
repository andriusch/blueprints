module Blueprints
  class Plan < Buildable
    def initialize(name, &block)
      super(name)
      @block = block
    end

    def build_plan
      surface_errors do
        if @block
          @result = Namespace.root.context.module_eval(&@block)
          Namespace.root.add_variable(path, @result)
        end
      end unless Namespace.root.executed_plans.include?(path)
      Namespace.root.executed_plans << path
      @result
    end

    private

    def surface_errors
      yield
    rescue StandardError => error
      puts "\n=> There was an error building scenario '#{@name}'", error.inspect, '', error.backtrace
      raise error
    end
  end
end