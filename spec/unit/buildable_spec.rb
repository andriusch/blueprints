require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::Buildable do
  before do
    mock = @mock
    @blueprint = Blueprints::Blueprint.new(:blueprint, __FILE__) { mock }
  end

  describe "normalize attributes" do
    it "should allow passing dependent normalize Blueprints::Dependency object" do
      Blueprints::Buildable.normalize_attributes(:name => Blueprints::Dependency.new(:blueprint)).should == {:name => @mock} 
    end
  end
end
