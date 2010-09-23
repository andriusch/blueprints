# Class for defining blueprint dependencies. Accepts up to 3 params:
# * name - pass the name of blueprint to build when trying to access value of this dependency.
# * iv_name (optional) - pass the name of instance variable to use for value. Defaults to same name as blueprint name.
# * options (optional) - pass options that are then passed to blueprint when building.
# Examples:
#   Blueprints::Dependency.new(:blueprint).value # Builds blueprint 'blueprint' and returns value of @blueprint instance variable
#   Blueprints::Dependency.new(:blueprint, value).value # Builds blueprint 'blueprint' and returns value of @value instance variable
#   Blueprints::Dependency.new(:blueprint, :option => true).value # Builds blueprint 'blueprint' with options and returns value of @value instance variable
#
# Blueprints::Dependency objects also catch all missing methods. They are later replayed on instance variable when getting value. Example:
#   d = Blueprints::Dependency.new(:blueprint).name.size
#   d.value # => 4 when @blueprint.name == 'John'
class Blueprints::Dependency
  instance_methods.each { |m| undef_method m if m =~ /^(to_|id$)/ }

  # Initializes new copy of Blueprints::Dependency with name, iv_name and options.
  def initialize(name, *args)
    @name = name
    @options = args.extract_options!
    @iv_name = (args.first || @name).to_s.gsub('.', '_')
    @registry = []
  end

  # Builds blueprint (if necessary) and returns the value of instance variable.
  def blueprint_value
    Blueprints::RootNamespace.root.build @name => @options
    @registry.inject(Blueprints::RootNamespace.root.context.instance_variable_get(:"@#{@iv_name}")) do |value, (method, args, block)|
      value.send(method, *args, &block)
    end
  end

  # Catches all missing methods to later replay when asking for value.
  def method_missing(method, *args, &block)
    @registry << [method, args, block]
    self
  end
end
