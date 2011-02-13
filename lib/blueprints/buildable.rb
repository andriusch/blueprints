module Blueprints
  class Buildable
    delegate :namespace, :dependencies, :to => :@context
    attr_reader :name

    # Initializes new Buildable object by name and context which it belongs to.
    # @param [#to_sym, Hash] name Name of buildable. If hash is passed then first key is assumed name, and
    #   value(s) of that key are assumed as dependencies.
    # @param [Blueprints::Context] context Context of buildable that later might get updated.
    # @raise [TypeError] If name is invalid.
    def initialize(name, context)
      @context = context

      name = self.class.infer_name(attributes) if name.nil?
      @name, parents = parse_name(name)
      depends_on(*parents)

      namespace.add_child(self) if namespace
    end

    # Returns class, name, attributes and dependencies of buildable in nice formatted string.
    # @return [String] Inspected properties of buildable.
    def inspect
      "<##{self.class} name: #{full_name.inspect}, attributes: #{attributes.inspect}, dependencies: #{dependencies.inspect}>"
    end

    # Defines dependencies of buildable by updating it's context.
    # @param [Array<String, Symbol>] dependencies List of dependencies.
    def depends_on(*dependencies)
      update_context(:dependencies => dependencies)
    end

    # @overload attributes
    #   Returns attributes of buildable
    #   @return [Hash] Attributes of buildable
    # @overload attributes(value)
    #   Merges attributes of buildable with new attributes by updating context
    #   @param [Hash] Updated attributes
    def attributes(value = nil)
      if value
        update_context(:attributes => value)
      else
        @context.attributes
      end
    end

    # Builds dependencies of blueprint and then blueprint itself.
    # @param [Blueprints::EvalContext] eval_context Context to build buildable object in.
    # @param [true, false] build_once Used if buildable is already built. If true then old one is updated else buildable is built again.
    # @param [Hash] options List of options to be accessible in the body of a blueprint.
    def build(eval_context, build_once = true, options = {})
      return result(eval_context) if @building or (built? and build_once and options.blank?)
      @building = true

      each_namespace { |namespace| namespace.build_parents(eval_context) }
      build_parents(eval_context)

      result = build_self(eval_context, build_once, options)
      Namespace.root.executed_blueprints << self

      @building = false
      result
    end

    # Returns if blueprint has been built
    # @return [true, false] true if was built, false otherwise
    def built?
      Namespace.root.executed_blueprints.include?(self)
    end

    # Marks blueprint as not built
    def undo!
      Namespace.root.executed_blueprints.delete self
    end

    # Returns full path to this buildable
    # @param [String] join_with Separator used to join names of parent namespaces and buildable itself.
    # @return [String] full path to this buildable joined with separator
    def path(join_with = '_')
      (namespace.path(join_with) + join_with unless namespace.nil? or namespace.path.empty?).to_s + @name.to_s
    end

    # Returns full name for this buildable
    # @return [String] full buildable name
    def full_name
      path('.')
    end

    # Builds all dependencies. Should be called before building itself. Searches dependencies first in parent then in root namespace.
    # @param [Blueprints::EvalContext] eval_context Context to build parents against.
    # @raise [Blueprints::BlueprintNotFoundError] If one of dependencies can't be found.
    def build_parents(eval_context)
      @context.dependencies.each do |name|
        parent = begin
          namespace[name]
        rescue BlueprintNotFoundError
          Namespace.root[name]
        end

        parent.build(eval_context)
      end
    end

    # Infers name of buildable using default attributes from Blueprints.config
    # @param [Hash] attributes Attributes of buildable object to infer the name from.
    # @return [String] Inferred name
    def self.infer_name(attributes)
      default_attribute = Blueprints.config.default_attributes.detect { |attribute| attributes.has_key?(attribute) }
      attributes[default_attribute].parameterize('_') if default_attribute
    end

    protected

    def each_namespace
      namespace = self
      yield(namespace) while namespace = namespace.namespace
    end

    def variable_name
      :"@#{path}"
    end

    def parse_name(name)
      if name.is_a?(Hash)
        return name.keys.first.to_sym, [name.values.first].flatten.map { |sc| parse_name(sc).first }
      elsif name.respond_to?(:to_sym)
        name = name.to_sym unless name == ''
        return name, []
      else
        raise TypeError, "Pass blueprint names as strings or symbols only, cannot define blueprint #{name.inspect}"
      end
    end

    def update_context(options)
      @context = @context.with_context(options)
      self
    end

    private

    def result(eval_context)
      if block_given?
        yield.tap do |result|
          if @auto_variable or not eval_context.instance_variable_defined?(variable_name)
            eval_context.instance_variable_set(variable_name, result)
            @auto_variable = true
          end
        end
      else
        eval_context.instance_variable_get(variable_name)
      end
    end
  end
end
