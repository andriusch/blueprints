module Blueprints
  # Is raised when blueprint or namespace is not found.
  class BlueprintNotFoundError < NameError
    def initialize(*args)
      @blueprints = args
    end

    def to_s
      "Blueprint/namespace not found '#{@blueprints.join(',')}'"
    end
  end
end
