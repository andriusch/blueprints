def file
  __FILE__
end

def mock1
  @mock ||= Mocha::Mockery.instance.unnamed_mock
end

def mock2
  @mock2 ||= Mocha::Mockery.instance.unnamed_mock
end

def stage
  @stage ||= Blueprints::EvalContext.new
end

def context
  @context ||= Blueprints::Context.new(:file => file, :namespace => Blueprints::Namespace.root)
end

def context2
  @context2 ||= Blueprints::Context.new(:parent => context, :namespace => namespace)
end

def context_with_attrs_and_deps
  @context_with_attrs_and_deps ||= Blueprints::Context.new(:attributes => {:attr1 => 1, :attr2 => 2}, :dependencies => [:dep1, :dep2], :file => file, :namespace => namespace)
end

def blueprint(&block)
  result = mock1
  block ||= proc { result }
  @blueprint ||= context.blueprint(:blueprint, &block)
end

def blueprint2(&block)
  result = mock1
  block ||= proc { result }
  @blueprint2 ||= context.blueprint(:blueprint2, &block)
end

def options_blueprint
  result, value = mock1, mock2
  @options_blueprint ||= Blueprints::Blueprint.new(:options_blueprint, context) do
    @value = value
    options.present? ? options : result
  end
end

def namespace
  @namespace ||= context.namespace(:namespace)
end

def namespace_blueprint
  result = mock1
  @namespace_blueprint ||= context2.blueprint(:blueprint) { result }
end

def namespace_blueprint2
  result = mock2
  @namespace_blueprint2 ||= context2.blueprint(:blueprint2) { result }
end
