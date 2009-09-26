module Blueprints
  module FileContext
    def self.blueprint(plan, &block)
      Plan.new(plan, &block)
    end
  end
end