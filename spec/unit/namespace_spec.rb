require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::Namespace do
  describe "demolish" do
    it "should allow to demolish namespace" do
      blueprint
      namespace_blueprint
      namespace_blueprint2
      results = Blueprints::Namespace.root.build :namespace
      results.each { |result| result.expects(:destroy) }

      @namespace.demolish
    end
  end
end
