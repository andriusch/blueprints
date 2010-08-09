module Blueprints
  # Module that blueprints file is executed against. Defined <tt>blueprint</tt> and <tt>namespace</tt> methods.
  class FileContext
    @@current = nil
    cattr_accessor :current
    attr_reader :file

    def initialize(file)
      file = Pathname.new(file)
      @file = file.relative_path_from(Blueprints.config.root)
      FileContext.current = self
      instance_eval(File.read(file))
      FileContext.current = nil
    end

    # Creates a new blueprint by name and block passed
    def blueprint(name, &block)
      Blueprint.new(name, @file, &block)
    end

    # Creates new namespace by name, and evaluates block against it.
    def namespace(name)
      old_namespace = Namespace.root
      namespace = Namespace.new(name)
      Namespace.root = namespace
      yield
      old_namespace.add_child(namespace)
      Namespace.root = old_namespace
      namespace
    end

    # Wrapper around Blueprints::Dependency.new. See Blueprints::Dependency for more information.
    def d(*args)
      Dependency.new(*args)
    end
  end
end
