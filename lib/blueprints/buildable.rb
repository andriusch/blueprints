module Blueprints
  class Buildable
    attr_reader :name
    attr_accessor :namespace

    # Initializes new Buildable object by name and namespace which it belongs to.
    # Name can be Symbol, String or Hash. If Hash is passed, then first key is assumed name, and value(s) of that key
    # are assumed as dependencies. Raises error class of name parameter is not what is expected.
    # Warns if name has already been taken.
    def initialize(name, namespace)
      @name, parents = parse_name(name)
      depends_on(*parents)

      if namespace
        Blueprints.warn("Overwriting existing blueprint", self) if namespace.children[@name]
        namespace.add_child(self)
      end
    end

    # Defines blueprint dependencies. Used internally, but can be used externally too.
    def depends_on(*scenarios)
      @parents = (@parents || []) + scenarios.map { |s| s.to_sym }
      self
    end

    # Builds dependencies of blueprint and then blueprint itself.
    #
    # +build_once+ - pass false if you want to build blueprint again instead of updating old one.
    #
    # +options+ - list of options to be accessible in the body of a blueprint. Defaults to empty Hash.
    def build(build_once = true, options = {})
      return result if @building or (built? and build_once and options.blank?)
      @building = true

      each_namespace {|namespace| namespace.build_parents }
      build_parents

      old_options, old_attributes = Namespace.root.context.options, Namespace.root.context.attributes
      Namespace.root.context.options, Namespace.root.context.attributes = options, normalized_attributes.merge(options)
      each_namespace {|namespace| Namespace.root.context.attributes.reverse_merge! namespace.normalized_attributes }

      build_self(build_once)
      Namespace.root.context.options, Namespace.root.context.attributes = old_options, old_attributes
      Namespace.root.executed_blueprints << self
      @building = false
      result
    end

    # Returns the result of blueprint
    def result
      Namespace.root.context.instance_variable_get(variable_name)
    end

    # Sets the result of blueprint
    def result=(value)
      Namespace.root.add_variable(variable_name, value)
    end

    # Returns if blueprint has been built
    def built?
      Namespace.root.executed_blueprints.include?(self)
    end

    # Marks blueprint as not built
    def undo!
      Namespace.root.executed_blueprints.delete self
    end

    # Returns full path to this buildable
    def path(join_with = '_')
      @path = (namespace.path(join_with) + join_with unless namespace.nil? or namespace.path.empty?).to_s + @name.to_s
    end

    # If value is passed then it sets attributes for this buildable object.
    # Otherwise returns attributes (defaulting to empty Hash)
    def attributes(value)
      @attributes = value
      self
    end

    # Returns normalized attributes for that particular blueprint.
    def normalized_attributes
      Buildable.normalize_attributes(@attributes ||= {})
    end

    # Normalizes attributes by changing all :@var to values of @var, and all dependencies to the result of that blueprint.
    def self.normalize_attributes(attributes)
      attributes.each_with_object({}) do |(attr, value), hash|
        hash[attr] = if value.respond_to?(:blueprint_value) then value.blueprint_value else value end
      end
    end

    def build_parents
      @parents.each do |p|
        parent = begin
          namespace[p]
        rescue BlueprintNotFoundError
          Namespace.root[p]
        end

        parent.build
      end
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
      case name
        when Hash
          return name.keys.first.to_sym, [name.values.first].flatten.map { |sc| parse_name(sc).first }
        when Symbol, String
          name = name.to_sym unless name == ''
          return name, []
        else
          raise TypeError, "Pass blueprint names as strings or symbols only, cannot define blueprint #{name.inspect}"
      end
    end
  end
end
