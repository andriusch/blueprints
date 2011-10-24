require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::Namespace do
  describe "children" do
    it "should allow adding children to namespace" do
      namespace.add_child(blueprint)
      namespace[:blueprint].should == blueprint
    end

    it "should warn when adding children overwrites existing one" do
      namespace_blueprint
      $stderr.expects(:puts).with("**WARNING** Overwriting existing blueprint: 'blueprint'")
      $stderr.expects(:puts).with(regexp_matches(/namespace_spec\.rb:14/))
      namespace.add_child(blueprint)
    end

    it "should return children" do
      namespace_blueprint
      namespace.children.should == [namespace_blueprint]
    end

    it "should allow recursive finding of children" do
      namespace_blueprint
      Blueprints::Namespace.root['namespace.blueprint'].should == namespace_blueprint
    end

    it "should raise error if blueprint can't be found" do
      namespace_blueprint
      expect {
        Blueprints::Namespace.root['namespace.blueprint2']
      }.to raise_error(Blueprints::BlueprintNotFoundError)
    end

    it "should find children with regexp names" do
      namespace_regexp_blueprint
      namespace['regexp_bp'].instance_variable_get(:@buildable).should == namespace_regexp_blueprint
      namespace.instance_variable_get(:@children).should have_key(:regexp_bp)
    end
  end

  describe "children context" do
    before do
      namespace_blueprint
    end

    it "should update attributes and dependencies of children when updating those of namespace" do
      namespace.attributes(:parent => 1).depends_on(:parent_depends)
      namespace_blueprint.attributes[:parent].should == 1
      namespace_blueprint.dependencies.should include(:parent_depends)
    end
  end

  describe "build" do
    before do
      blueprint
      namespace_blueprint
      namespace_blueprint2
    end

    it "should set result to results of all blueprints in namespace" do
      result = namespace.build(stage)
      result.should =~ [mock1, mock2]
    end

    it "should pass options and eval context params" do
      namespace_blueprint.expects(:build).with(stage, :option => 'value')
      namespace_blueprint2.expects(:build).with(stage, :option => 'value')
      namespace.build(stage, :option => 'value')
    end

    it "should build default blueprint if one exists" do
      namespace_default_blueprint.expects(:build)
      namespace_blueprint.expects(:build).never
      namespace.build(stage)
    end
  end

  describe "demolish" do
    it "should allow to demolish namespace" do
      blueprint
      namespace_blueprint
      namespace_blueprint2
      results = namespace.build stage
      results.each { |result| result.expects(:destroy) }

      @namespace.demolish(stage)
    end
  end
end
