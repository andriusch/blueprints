require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::RootNamespace do
  it "should allow building blueprints with regexp name" do
    namespace_regexp_blueprint
    Blueprints::Namespace.root.build(['namespace.regexp_blueprint'], stage)
    stage.instance_variable_get(:@namespace_regexp_blueprint).should == {:arg0 => "blueprint"}
  end
end
