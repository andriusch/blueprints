module Blueprints
  class Error < StandardError
    def initialize(blueprint)
      @name = blueprint
    end

    def to_s
      "Blueprint '#{@name}' #{message_append}"
    end
  end

  class DemolishError < Error
    def message_append
      'must be built before demolishing'
    end
  end

  # Is raised when blueprint or namespace is not found.
  class BlueprintNotFoundError < Error
    def message_append
      'not found'
    end
  end
end
