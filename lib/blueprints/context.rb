module Blueprints
  # Class that blueprint blocks are evaluated against. Allows you to access options that were passed to build method.
  class Context
    attr_accessor :options, :attributes

    # Method that allows building one blueprint inside of another. Simply delegates to root namespace.
    def build(*names)
      Namespace.root.build(*names)
    end
  end
end
