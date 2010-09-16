def mock1
  @mock ||= Mocha::Mockery.instance.unnamed_mock
end

def mock2
  @mock2 ||= Mocha::Mockery.instance.unnamed_mock
end

def blueprint
  result = mock1
  @blueprint ||= Blueprints::Blueprint.new(:blueprint, Blueprints::Namespace.root, __FILE__) { result }
end

def blueprint2
  result = mock1
  @blueprint2 ||= Blueprints::Blueprint.new(:blueprint2, Blueprints::Namespace.root, __FILE__) { result }
end

def options_blueprint
  result, value = mock1, mock2
  @options_blueprint ||= Blueprints::Blueprint.new(:options_blueprint, Blueprints::Namespace.root, __FILE__) do
    @value = value
    options.present? ? options : result
  end
end

def namespace
  @namespace ||= Blueprints::Namespace.new(:namespace, Blueprints::Namespace.root)
end

def namespace_blueprint
  result = mock1
  @namespace_blueprint ||= Blueprints::Blueprint.new(:blueprint, namespace, __FILE__) { result }
end

def namespace_blueprint2
  result = mock2
  @namespace_blueprint2 ||= Blueprints::Blueprint.new(:blueprint2, namespace, __FILE__) { result }
end
