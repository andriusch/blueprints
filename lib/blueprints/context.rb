module Blueprints
  # Class that blueprint files are evaluated against. Has methods for setting and retrieving attributes and dependencies.
  # Allows defining new blueprints and namespaces.
  class Context
    @@chain = []

    attr_reader :dependencies, :file

    # Initializes new context with passed parent, attributes, dependencies, file and namespace.
    # Attributes and dependencies are automatically merged with parents' attributes and dependencies.
    # File and namespace are automatically set to parent counterparts unless they are explicitly changed.
    # @param [Hash] options Options for new context.
    # @option options [Hash] :attributes ({}) List of attributes, merged with parent attributes.
    # @option options [Array<String, Symbol>] :dependencies ([]) List of dependencies, merged with parent dependencies.
    # @option options [Pathname] :file File this context is evaluated in. Should be passed for top level contexts only.
    # @option options [Blueprints::Namespace] :namespace Namespace that new blueprints and namespaces should be children of.
    # @option options [Blueprints::Context] :parent Parent context that is used to retrieve unchanged values.
    def initialize(options = {})
      options.assert_valid_keys(:dependencies, :attributes, :file, :parent, :namespace)
      @dependencies = (options[:dependencies] || []).collect(&:to_sym)
      @attributes   = options[:attributes] || {}
      @file         = options[:file]
      @namespace    = options[:namespace]

      if parent = options[:parent]
        @attributes.reverse_merge!(parent.attributes)
        @dependencies = (parent.dependencies + @dependencies).uniq
        @file         ||= parent.file
        @namespace    ||= parent.namespace
      end
    end

    # Checks if two contexts are equal by comparing attributes, dependencies, namespace and file
    # @param [Blueprints::Context] context Context to compare this one to.
    # @return [true, false] Whether contexts are equal or not.
    def ==(context)
      @dependencies == context.dependencies and @attributes == context.attributes and @file == context.file and @namespace == context.namespace
    end

    # Defines a new blueprint by name and block passed.
    # @example Define blueprint.
    #   blueprint :user do
    #     User.blueprint :name => 'User'
    #   end
    # @param name (see Buildable#initialize)
    # @return [Blueprints::Blueprint] Newly defined blueprint.
    def blueprint(name = nil, &block)
      Blueprint.new(name, self, &block)
    end

    # @overload namespace(name, &block)
    #   Defines new namespace by name, and evaluates block against it.
    #   @example Define namespace and blueprint in it.
    #     namespace :banned do
    #       blueprint :user do
    #         User.blueprint :name => 'User'
    #       end
    #     end
    #   @param [String, Symbol] name Name of namespace.
    #   @return [Blueprints::Namespace] Newly defined namespace.
    # @overload namespace
    #   Returns namespace for this context.
    #   @return [Blueprints::Namespace] Namespace for this context.
    def namespace(name = nil, &block)
      if name
        Namespace.new(name, self).tap do |namespace|
          with_context(:namespace => namespace, &block)
        end
      else
        @namespace
      end
    end

    # @overload attributes(new_attributes, &block)
    #   Yields and returns child context that has new attributes set.
    #   @example Define blueprint with attributes
    #     attributes(:name => 'User').blueprint(:user) do
    #       User.blueprint attributes
    #     end
    #   @example Define multiple blueprints with same attributes
    #     attributes(:name => 'User') do
    #       blueprint(:user1) do
    #         User.blueprint attributes
    #       end
    #
    #       blueprint(:user2) do
    #         User.blueprint attributes
    #       end
    #     end
    #   @param [Hash] new_attributes Attributes for child context.
    #   @return [Blueprints::Context] Child context
    # @overload attributes
    #   Returns attributes of context.
    #   @return [Hash] Attributes of context.
    def attributes(new_attributes = nil, &block)
      if new_attributes
        with_context(:attributes => new_attributes, &block)
      else
        @attributes
      end
    end

    # Yields and returns child context that has dependencies set.
    # @example Define blueprint with dependencies
    #   depends_on(:user, :admin).blueprint(:user_and_admin)
    # @example Define multiple blueprints with same dependencies.
    #   depends_on :user, :admin do
    #     blueprint :user_and_admin
    #     blueprint :admin_and_user
    #   end
    # @param [Array<Symbol, String>] new_dependencies Dependencies for child context.
    # @return [Blueprints::Context] Child context
    def depends_on(*new_dependencies, &block)
      with_context(:dependencies => new_dependencies, &block)
    end

    # Yields and returns child context that has new options set.
    # @param options (see Context#initialize)
    # @return [Blueprints::Context] Child context
    def with_context(options, &block)
      Context.eval_within_context(options.merge(:parent => self), &block)
    end

    # Initializes new Blueprints::Dependency object.
    # @overload d(name, options = {})
    #   @param name (see Dependency#initialize)
    #   @param options (see Dependency#initialize)
    # @overload d(name, instance_variable_name, options = {})
    #   @param name (see Dependency#initialize)
    #   @param instance_variable_name (see Dependency#initialize)
    #   @param options (see Dependency#initialize)
    def d(*args)
      Dependency.new(*args)
    end

    # Finds blueprint/namespace by it's path
    # @param path (see Namespace#[])
    # @return (see Namespace#[])
    def find(path)
      @namespace[path]
    end
    alias [] find

    # Return current context.
    # @return [Blueprints::Context] Current context.
    def self.current
      @@chain.last
    end

    # Creates child context and sets it as current. Evaluates block and file within child context if any are passed.
    # @param [Hash] new_options Options for child context.
    def self.eval_within_context(new_options, &block)
      @@chain << context = new(new_options)

      file = new_options[:file]
      context.instance_eval(File.read(file), file) if file
      context.instance_eval(&block) if block

      @@chain.pop
    end
  end
end
