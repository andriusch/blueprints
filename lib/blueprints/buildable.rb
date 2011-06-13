module Blueprints
  class Buildable
    BUILDING_MESSAGE = 'While building blueprint'
    
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

    # Builds dependencies of buildable and then buildable itself.
    # @param [Object] environment Context to build buildable object in.
    # @param [Hash] options List of options to build this buildable with.
    # @option options [Hash] :options ({}) List of options to be accessible in the body of a blueprint.
    # @option options [true, false] :rebuild (false) If true this buildable is treated as not built yet and is rebuilt even if it was built before.
    # @option options [Symbol] :strategy (:default) Strategy to use when building.
    # @option options [Symbol] :name Name of blueprint to use when building. Is usually passed for blueprints with regexp names.
    def build(environment, options = {})
      return result(environment) if @building or (built? and not options[:rebuild] and options[:options].blank?)
      @building = true

      result = nil
      surface_errors do
        each_namespace { |namespace| namespace.build_parents(environment) }
        build_parents(environment)
        result = build_self(environment, options)
      end
      Namespace.root.executed_blueprints << self

      result
    ensure
      @building = false
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
    # @param [#to_s] current_name Current name of this buildable. Used for regexp named buildables. Defaults to @name.
    # @return [String] full path to this buildable joined with separator
    def path(join_with = '_', current_name = nil)
      current_name ||= @name
      namespace_path = namespace.path(join_with) if namespace
      [namespace_path.presence, current_name].compact.join(join_with)
    end

    # Returns full name for this buildable
    # @return [String] full buildable name
    def full_name
      path('.')
    end

    # Builds all dependencies. Should be called before building itself. Searches dependencies first in parent then in root namespace.
    # @param [Object] environment Context to build parents against.
    # @raise [Blueprints::BlueprintNotFoundError] If one of dependencies can't be found.
    def build_parents(environment)
      @context.dependencies.each do |name|
        parent = begin
          namespace[name]
        rescue BlueprintNotFoundError
          Namespace.root[name]
        end

        parent.build(environment)
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

    def variable_name(current_name = nil)
      :"@#{path('_', current_name || @name)}"
    end

    def parse_name(name)
      if name.is_a?(Hash)
        return name.keys.first.to_sym, [name.values.first].flatten.map { |sc| parse_name(sc).first }
      elsif name.respond_to?(:to_sym)
        name = name.to_sym unless name == ''
        return name, []
      elsif name.is_a? Regexp
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

    def result(environment, current_name = nil)
      variable_name = self.variable_name(current_name)
      if block_given?
        yield.tap do |result|
          if @auto_variable or not environment.instance_variable_defined?(variable_name)
            environment.instance_variable_set(variable_name, result)
            @auto_variable = true
          end
        end
      else
        environment.instance_variable_get(variable_name)
      end
    end

    def surface_errors
      yield
    rescue StandardError => error
      insert_at = error.backtrace.index { |line| line !~ /^#{BUILDING_MESSAGE}/ }
      error.backtrace.insert(insert_at, "#{BUILDING_MESSAGE} '#{path}'")
      raise
    end
  end
end
