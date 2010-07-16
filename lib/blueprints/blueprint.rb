module Blueprints
  # Class for actual blueprints. Allows building itself by executing block passed against current context.
  class Blueprint < Buildable
    attr_reader :file
    # Initializes blueprint by name and block
    def initialize(name, file, &block)
      @file = file
      super(name)
      @block = block
    end

    # Builds blueprint and adds it to executed blueprint hash. Setups instance variable with same name as blueprint if it is not defined yet.
    def build_self(build_once = true)
      surface_errors { @result = Namespace.root.context.instance_eval(&@block) if @block }
    end

    # Changes blueprint block to build another blueprint by passing additional options to it. Usually used to dry up
    # blueprints that are often built with some options.
    def extends(parent, options)
      attributes(options)
      @block = Proc.new { build parent => attributes }
    end

    def backtrace(trace)
      trace.collect {|line| line.sub(/^\(eval\):(\d+).*/, "#{@file}:\\1:in blueprint '#{@name}'") }
    end

    private

    def surface_errors
      yield
    rescue StandardError => error
      error.set_backtrace(backtrace(error.backtrace))
      raise error
    end
  end
end
