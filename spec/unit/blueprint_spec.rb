require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::Blueprint do
  before do
    blueprint
  end

  it "should warn when blueprint with same name exists" do
    STDERR.expects(:puts).with("**WARNING** Overwriting existing blueprint: 'blueprint'")
    STDERR.expects(:puts).with(regexp_matches(/blueprint_spec\.rb:\d+:in `.+'/))
    Blueprints::Blueprint.new(blueprint.name, blueprint.namespace, blueprint.file)
  end

  it 'should raise TypeError when scenario name is not symbol or string' do
    lambda {
      Blueprints::Blueprint.new(1, blueprint.namespace, blueprint.file)
    }.should raise_error(TypeError, "Pass blueprint names as strings or symbols only, cannot define blueprint 1")
  end

  describe "building" do
    it "should mark blueprint as built" do
      lambda {
        Blueprints::Namespace.root.build :blueprint
      }.should change(@blueprint, :used?).from(nil).to(true)
    end
  end

  describe "demolish" do
    before do
      @result = Blueprints::Namespace.root.build :blueprint
      @result.stubs(:destroy)
    end

    it "should allow to demolish blueprint" do
      @result.expects(:destroy)
      blueprint.demolish
    end

    it "should raise error if blueprint is not built" do
      blueprint.demolish
      lambda { blueprint.demolish }.should raise_error(Blueprints::DemolishError)
    end

    it "should set blueprint as not built" do
      blueprint.demolish
      Blueprints::Namespace.root.executed_blueprints.should_not include(blueprint)
    end

    it "should allow to customize demolishing" do
      @result.expects(:demolish)
      blueprint.demolish { @blueprint.demolish }
      blueprint.demolish
    end
  end

  describe "updating" do
    before do
      @result = Blueprints::Namespace.root.build :blueprint
    end

    it "should allow building blueprint with different parameters" do
      @result.expects(:blueprint).with(:option => 'value')
      Blueprints::RootNamespace.root.build(:blueprint => {:option => 'value'})
    end

    it "should allow customizing update block" do
      blueprint.update { @blueprint.update_attributes(options) }
      @result.expects(:update_attributes).with(:option => 'value')
      Blueprints::RootNamespace.root.build(:blueprint => {:option => 'value'})
    end

    it "should not update if build_once is false" do
      Blueprints::RootNamespace.root.build({:blueprint => {:option => 'value'}}, nil, false)
    end
  end
end
