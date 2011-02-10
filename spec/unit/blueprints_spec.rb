require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints do
  describe "usage" do
    before do
      blueprint
      blueprint2
      namespace_blueprint
      namespace_blueprint2
    end

    it "should allow getting unused blueprints" do
      Blueprints::Namespace.root.build [:blueprint, :"namespace.blueprint2"], stage
      Blueprints.unused.should =~ ['blueprint2', 'namespace.blueprint']
    end

    describe "most used" do
      before do
        Blueprints::Namespace.root.build [:blueprint, :blueprint2, :"namespace.blueprint"], stage
        Blueprints::Namespace.root.executed_blueprints.clear
        Blueprints::Namespace.root.build [:blueprint2, :"namespace.blueprint"], stage
        Blueprints::Namespace.root.executed_blueprints.clear
        Blueprints::Namespace.root.build [:"namespace.blueprint"], stage
      end

      it "should return all blueprints with their usages" do
        Blueprints.most_used.should == [["namespace.blueprint", 3], ["blueprint2", 2], ["blueprint", 1], ["namespace.blueprint2", 0]]
      end

      it "should allow getting most used blueprints" do
        Blueprints.most_used(:count => 2).should == [['namespace.blueprint', 3], ['blueprint2', 2]]
      end

      it "should allow getting list of blueprints used at least n times" do
        Blueprints.most_used(:at_least => 1).should == [['namespace.blueprint', 3], ['blueprint2', 2], ["blueprint", 1]]
      end

      it "should allow mixing at least with count" do
        Blueprints.most_used(:at_least => 2, :count => 3).should == [['namespace.blueprint', 3], ['blueprint2', 2]]
        Blueprints.most_used(:at_least => 2, :count => 1).should == [['namespace.blueprint', 3]]
      end
    end
  end
end
