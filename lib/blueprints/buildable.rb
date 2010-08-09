module Blueprints
  class Buildable
    class Dependency < Struct.new(:name) # :nodoc:
      alias :to_sym :name

      def iv_name
        :"@#{name}"
      end
    end

    attr_reader :name
    attr_accessor :namespace

    # Initializes new Buildable object by name.
    # Name can be Symbol, String or Hash. If Hash is passed, then first key is assumed name, and value(s) of that key
    # are assumed as dependencies. Raises error class of name parameter is not what is expected.
    # Warns if name has already been taken.
    def initialize(name)
      @name, parents = parse_name(name)
      depends_on(*parents)

      Blueprints.warn("Overwriting existing blueprint", self) if Namespace.root and Namespace.root.children[@name]
      Namespace.root.add_child(self) if Namespace.root
    end

    # Defines blueprint dependencies. Used internally, but can be used externally too.
    def depends_on(*scenarios)
      @parents = (@parents || []) + scenarios.map{|s| s.to_sym}
      self
    end

    # Builds dependencies of blueprint and then blueprint itself.
    #
    # +build_once+ - pass false if you want to build blueprint again instead of updating old one.
    #
    # +options+ - list of options to be accessible in the body of a blueprint. Defaults to empty Hash.
    def build(build_once = true, options = {})
      return @result if (built? or Namespace.root.executed_blueprints.include? self) and build_once
      Namespace.root.executed_blueprints << self

      each_namespace {|namespace| namespace.build_parents }
      build_parents

      old_options, old_attributes = Namespace.root.context.options, Namespace.root.context.attributes
      Namespace.root.context.options, Namespace.root.context.attributes = options, normalized_attributes.merge(options)
      each_namespace {|namespace| Namespace.root.context.attributes.reverse_merge! namespace.normalized_attributes }

      build_self(build_once)
      Namespace.root.context.options, Namespace.root.context.attributes = old_options, old_attributes
      Namespace.root.add_variable(path, @result)
    end

    # Returns if blueprint has been built
    def built?
      instance_variable_defined?(:@result)
    end

    # Marks blueprint as not built
    def undo!
      remove_instance_variable(:@result) if built?
      Namespace.root.executed_blueprints.delete self
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
      attributes = attributes.dup
      attributes.each do |attr, value|
        if value.is_a?(Blueprints::Buildable::Dependency)
          Blueprints::Namespace.root.build(value.name)
          attributes[attr] = Blueprints::Namespace.root.context.instance_variable_get(value.iv_name)
        end
        if value.is_a? Symbol and value.to_s =~ /^@.+$/
          STDERR.puts "DEPRECATION WARNING: :@variables are deprecated in favor of `d` method"
          attributes[attr] = Blueprints::Namespace.root.context.instance_variable_get(value)
        end
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

    def path
      @path = (namespace.path + "_" unless namespace.nil? or namespace.path.empty?).to_s + @name.to_s
    end

    def parse_name(name)
      case name
        when Hash
          return name.keys.first.to_sym, [name.values.first].flatten.map{|sc| parse_name(sc).first}
        when Symbol, String
          name = name.to_sym unless name == ''
          return name, []
        else
          raise TypeError, "Pass blueprint names as strings or symbols only, cannot define blueprint #{name.inspect}"
      end
    end
  end
end
