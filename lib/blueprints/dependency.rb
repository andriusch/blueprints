# Class for defining blueprint dependencies.
class Blueprints::Dependency
  instance_methods.each { |m| undef_method m if m =~ /^(to_|id$)/ }

  # Initializes new Blueprints::Dependency object.
  # @example Build blueprint 'blueprint' and returns value of @blueprint instance variable.
  #   Blueprints::Dependency.new(:blueprint)
  # @example Build blueprint 'blueprint' and returns value of @value instance variable.
  #   Blueprints::Dependency.new(:blueprint, value)
  # @example Build blueprint 'blueprint' with options and returns value of @value instance variable.
  #   Blueprints::Dependency.new(:blueprint, :option => true)
  # @example Register called methods
  #   d = Blueprints::Dependency.new(:blueprint).name.size
  # @overload d(name, options = {})
  #   Use result of blueprint/namespace +name+ and pass options when building.
  #   @param [Symbol, String] name Name of blueprint/namespace.
  #   @param [Hash] options Options to pass when building blueprint/namespace.
  # @overload d(name, instance_variable_name, options = {})
  #   Build blueprint/namespace with options and use differently names instance variable as result.
  #   @param [Symbol, String] name Name of blueprint/namespace.
  #   @param [Symbol, String] instance_variable_name Name of instance variable to use as a result.
  #   @param [Hash] options Options to pass when building blueprint/namespace.
  def initialize(name, *args)
    @name     = name
    @options  = args.extract_options!
    @iv_name  = (args.first || @name).to_s.gsub('.', '_')
    @registry = []
  end

  # Returns block that builds blueprint (if necessary) takes instance variable for this dependency and calls all methods from method registry.
  # @return [Proc] Proc that can be called to return value for this dependency.
  def to_proc
    name, options, registry, variable_name = @name, @options, @registry, @iv_name
    Proc.new do
      build name => options
      registry.inject(instance_variable_get(:"@#{variable_name}")) do |value, (method, args, block)|
        value.send(method, *args, &block)
      end
    end
  end

  # Catches all missing methods to later replay when asking for value.
  # @return [Blueprints::Dependency] self
  def method_missing(method, *args, &block)
    @registry << [method, args, block]
    self
  end
end
