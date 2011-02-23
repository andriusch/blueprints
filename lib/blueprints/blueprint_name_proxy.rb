# Acts as a proxy to buildables with regexp names. Used for caching purposes. Remembers name used and always uses it later.
# Allows building and demolishing it's buildable.
class Blueprints::BlueprintNameProxy
  # Initializes new instance of proxy.
  # @param [Symbol] name Name of buildable that this proxy uses.
  # @param [Blueprints::Buildable] buildable Buildable itself, that can later be built of demolished.
  def initialize(name, buildable)
    @buildable = buildable
    @name = name

    match_data = buildable.name.match(name.to_s)
    names = match_data.names.collect(&:to_sym) if match_data.respond_to?(:names)
    names = (0...match_data.captures.size).collect { |ind| :"arg#{ind}" } if names.blank?
    @options = Hash[names.zip(match_data.captures)]
  end

  # Allows building buildable. Merges regexp match data into options. If named regexp captures are used (Ruby 1.9 only),
  # it will merge those names with appropriate values into options, otherwise options will be named arg0..n.
  # @param eval_context (see Buildable#build)
  # @param options (see Buildable#build)
  # @return (see Buildable#build)
  def build(eval_context, options = {})
    options[:options] ||= {}
    options[:options].merge!(@options)
    options.merge!(:name => @name)
    @buildable.build(eval_context, options)
  end

  # Allows demolishing buildable. Uses remembered name to determine name of variable to call destroy on.
  # @param [Object] eval_context Eval context that this buildable was built in.
  def demolish(eval_context)
    @buildable.demolish(eval_context, @name)
  end
end
