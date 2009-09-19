module Blueprints
  class PlanNotFoundError < NameError
    def initialize(*args)
      @plans = args
    end

    def to_s
      "Plan(s) not found '#{@plans.join(',')}'"
    end
  end
end