module Blueprints
  # Is raised when blueprint or namespace is not found.
  class PlanNotFoundError < NameError
    def initialize(*args)
      @plans = args
    end

    def to_s
      "Plan/namespace not found '#{@plans.join(',')}'"
    end
  end
end
