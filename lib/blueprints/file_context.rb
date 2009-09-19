module Blueprints
  module FileContext
    def self.plan(plan, &block)
      Plan.new(plan, &block)
    end
  end
end