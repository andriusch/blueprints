module Blueprints
  class Error < StandardError
    def initialize(blueprint)
      @name = blueprint
    end

    def to_s
      "Blueprint '#{@name}': #{message}"
    end
  end

  class DemolishError < Error
    def message
      'must be built before demolishing'
    end
  end

  # Is raised when blueprint or namespace is not found.
  class BlueprintNotFoundError < Error
    def message
      'not found'
    end
  end
end
