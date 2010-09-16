require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints do
  it "should allow getting unused blueprints" do
    blueprint
    blueprint2
    namespace_blueprint
    namespace_blueprint2

    Blueprints::Namespace.root.build [:blueprint, :"namespace.blueprint2"]
    Blueprints.unused.should =~ ['blueprint2', 'namespace.blueprint']
  end
end
