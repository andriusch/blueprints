module Blueprints
  # A helper module that should be included in test framework. Adds methods <tt>build</tt> and <tt>demolish</tt>
  module Helper
    # Builds one or more blueprints by their names. You can pass names as symbols or strings. You can also pass additional
    # options hash which will be available by calling <tt>options</tt> in blueprint block. Returns result of blueprint block.
    #   # build :apple and orange blueprints
    #   build :apple, :orange
    #
    #   # build :apple scenario with additional options
    #   build :apple => {:color => 'red'}
    #
    #   # options can also be passed for several blueprints
    #   build :pear, :apple => {:color => 'red'}, :orange => {:color => 'orange'}
    def build(*names)
      Namespace.root.build(names, self, true)
    end

    # Same as #build_blueprint except that you can use it to build same blueprint several times.
    def build!(*names)
      Namespace.root.build(names, self, false)
    end

    # Returns attributes that are used to build blueprint. To set what attributes are used you need to call attributes
    # method when defining blueprint like this:
    #   blueprint :apple do
    #     Fruit.build attributes
    #   end.attributes(:name => 'apple')
    def build_attributes(name)
      Namespace.root[name].build_parents
      Namespace.root[name].normalized_attributes.tap { Blueprints::Namespace.root.copy_ivars(self) }
    end

    # Returns Blueprint::Dependency object that can be used to define dependencies on other blueprints.
    def d(*args)
      Dependency.new(*args)
    end

    # Demolishes built blueprints (by default simply calls destroy method on result of blueprint, but can be customized).
    #
    #   demolish :apple, :pear
    def demolish(*names)
      names.each { |name| Namespace.root[name].demolish }
    end

    alias :build_blueprint :build
    alias :build_blueprint! :build!
    alias :blueprint_dependency :d
    alias :blueprint_demolish :demolish
  end
end
