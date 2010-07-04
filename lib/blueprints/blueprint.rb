module Blueprints
  # Class for actual blueprints. Allows building itself by executing block passed against current context.
  class Blueprint < Buildable
    # Initializes blueprint by name and block
    def initialize(name, &block)
      super(name)
      @block = block
    end

    # Builds blueprint and adds it to executed blueprint hash. Setups instance variable with same name as blueprint if it is not defined yet.
    def build_self(build_once = true)
      if build_once and Namespace.root.executed_blueprints.include?(path)
        Blueprints.warn("Building with options, but blueprint was already built", @name) if Namespace.root.context.options.present?
      else
        surface_errors do
          if @block
            @result = Namespace.root.context.instance_eval(&@block)
            Namespace.root.add_variable(path, @result)
          end
        end
      end
      Namespace.root.executed_blueprints << path
      @result
    end

    # Changes blueprint block to build another blueprint by passing additional options to it. Usually used to dry up
    # blueprints that are often built with some options.
    def extends(parent, options)
      attributes(options)
      @block = Proc.new { build parent => attributes }
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
