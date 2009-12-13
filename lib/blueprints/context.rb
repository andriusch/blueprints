module Blueprints
  # Class that blueprint blocks are evaluated against. Allows you to access options that were passed to build method.
  class Context
    attr_accessor :options
  end
end
