module Blueprints
  # A helper module that should be included in test framework. Adds methods <tt>build</tt> and <tt>demolish</tt>
  module Helper
    # Builds one or more blueprints by their names. You can pass names as symbols or strings. You can also pass additional
    # options hash which will be available by calling <tt>options</tt> in blueprint block. Returns result of last blueprint block.
    # @example build :apple and :orange blueprints.
    #   build :apple, :orange
    # @example build :apple blueprint with additional options.
    #   build :apple => {:color => 'red'}
    # @example passing options to several blueprints.
    #   build :pear, :apple => {:color => 'red'}, :orange => {:color => 'orange'}
    # @param [Array<Symbol, String, Hash>] names Names of blueprints/namespaces to build. Pass Hash if you want to pass additional options.
    # @return Return value of last blueprint
    def build(*names)
      Namespace.root.build(names, self)
    end

    # Same as Blueprints::Helper#build except that you can use it to build same blueprint several times.
    # @overload build!(*names)
    #   @param names (see Helper#build)
    #   @return (see Helper#build)
    # @overload build!(count, *names)
    #   @param [Integer] count Times to build passed blueprint
    #   @param names (see Helper#build)
    #   @return [Array] Array of return values of last blueprint, which is same size as count that you pass
    def build!(*names)
      if names.first.is_a?(Integer)
        (0...names.shift).collect { build! *names }
      else
        Namespace.root.build(names, self, :rebuild => true)
      end
    end

    # Same as Blueprints::Helper#build except it also allows you to pass strategy to use (#build always uses default strategy).
    # @param [Symbol] strategy Strategy to use when building blueprint/namespace.
    # @param names (see Helper#build)
    # @return (see Helper#build)
    def build_with(strategy, *names)
      Namespace.root.build(names, self, :strategy => strategy)
    end

    # Returns attributes that are used to build blueprint.
    # @example Setting and retrieving attributes.
    #   # In blueprint.rb file
    #   attributes(:name => 'apple').blueprint :apple do
    #     Fruit.build attributes
    #   end
    #
    #   # In spec/test file
    #   build_attributes :apple #=> {:name => 'apple'}
    # @param [Symbol, String] name Name of blueprint/namespace.
    # @return [Hash] Normalized attributes of blueprint/namespace
    def build_attributes(name)
      blueprint = Namespace.root[name]
      blueprint.build_parents(self)
      blueprint.normalized_attributes(self)
    end

    # Returns Blueprint::Dependency object that can be used to define dependencies on other blueprints.
    # @example Building :post blueprint with different user.
    #   build :post => {:user => d(:admin)}
    # @example Building :post blueprint by first building :user_profile with :name => 'John', then taking value of @profile and calling +user+ on it.
    #   build :post => {:user => d(:user_profile, :profile, :name => 'John').user}
    # @see Blueprints::Dependency#initialize Blueprints::Dependency for accepted arguments.
    # @return [Blueprints::Dependency] Dependency object that can be passed as option when building blueprint/namespace.
    def d(*args)
      Dependency.new(*args)
    end

    # Demolishes built blueprints (by default simply calls destroy method on result of blueprint, but can be customized).
    # @example Demolish :apple and :pear blueprints
    #   demolish :apple, :pear
    # @param [Array<Symbol, String>] names Names of blueprints/namespaces to demolish.
    def demolish(*names)
      names.each { |name| Namespace.root[name].demolish(self) }
    end

    alias :build_blueprint :build
    alias :build_blueprint! :build!
    alias :blueprint_dependency :d
    alias :blueprint_demolish :demolish
  end
end
