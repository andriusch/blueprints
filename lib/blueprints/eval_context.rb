module Blueprints
  class EvalContext
    # Copy instance variables to another object.
    # @param target Object to copy instance variables to.
    def copy_instance_variables(target)
      instance_variables.each do |iv_name|
        target.instance_variable_set(iv_name, instance_variable_get(iv_name))
      end
    end

    # Sets options and attributes and evaluates block against self.
    # @param [Blueprints::Context] context Context of buildable object. Used to extract attributes.
    # @param [Hash] options Options hash, merged into attributes.
    def instance_eval(context, options, &block)
      with_method(:options, options = normalize_hash(options)) do
        with_method(:attributes, normalize_hash(context.attributes).merge(options)) do
          super(&block)
        end
      end
    end

    # Builds blueprints by delegating to root namespace.
    # @param [Array<String, Symbol>] blueprints Names of buildables.
    # @return Result of last buildable.
    def build(*blueprints)
      Namespace.root.build(blueprints)
    end

    # Normalizes attributes hash by evaluating all Proc and Blueprints::Dependency objects against itself.
    # @param [Hash] hash Attributes hash.
    # @return [Hash] Normalized hash.
    def normalize_hash(hash)
      hash.each_with_object({}) do |(attr, value), normalized|
        normalized[attr] = if value.respond_to?(:to_proc) and not Symbol === value
                             instance_exec(&value)
                           else
                             value
                           end
      end
    end

    private

    def with_method(name, value)
      old_method = method(name) if respond_to?(name)
      singleton_class.class_eval do
        define_method(name) { value }
        yield.tap { define_method(name, &old_method) if old_method }
      end
    end
  end
end
