require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::Buildable do
  before do
    blueprint
  end

  describe "normalize attributes" do
    it "should allow passing dependent normalize Blueprints::Dependency object" do
      Blueprints::Buildable.normalize_attributes(:name => Blueprints::Dependency.new(:blueprint)).should == {:name => mock1}
    end
  end
end
