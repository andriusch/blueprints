module Blueprints
  # Module that blueprints file is executed against. Defined <tt>blueprint</tt> and <tt>namespace</tt> methods.
  class FileContext
    @@current = nil
    cattr_accessor :current
    attr_reader :file, :namespaces

    def initialize(file)
      file = Pathname.new(file)
      @file = file.relative_path_from(Blueprints.config.root)
      @namespaces = [Namespace.root]

      FileContext.current = self
      instance_eval(File.read(file))
      FileContext.current = nil
    end

    # Creates a new blueprint by name and block passed
    def blueprint(name, &block)
      Blueprint.new(name, @namespaces.last, @file, &block)
    end

    # Creates new namespace by name, and evaluates block against it.
    def namespace(name)
      @namespaces.push Namespace.new(name, @namespaces.last)
      yield
      @namespaces.pop
    end

    # Wrapper around Blueprints::Dependency.new. See Blueprints::Dependency for more information.
    def d(*args)
      Dependency.new(*args)
    end
  end
end
