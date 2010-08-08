require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::Namespace do
  before do
    mock = @mock

    old_root = Blueprints::Namespace.root
    @namespace = Blueprints::Namespace.root = Blueprints::Namespace.new(:namespace)
    Blueprints::Blueprint.new(:blueprint1, __FILE__) { mock }
    Blueprints::Blueprint.new(:blueprint2, __FILE__) { mock }
    Blueprints::Namespace.root = old_root

    Blueprints::Blueprint.new(:outside_namespace, __FILE__) { mock }
    Blueprints::Namespace.root.build :namespace
  end

  describe "demolish" do
    it "should allow to demolish namespace" do
      @mock.expects(:destroy).twice
      @namespace.demolish
    end
  end
end
