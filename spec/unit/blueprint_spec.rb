require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::Blueprint do
  it "should rewrite trace" do
    context         = Blueprints::Context.new(:file => __FILE__)
    error_blueprint = Blueprints::Blueprint.new(:error, context) { raise 'error' }
    begin
      error_blueprint.build(stage)
    rescue RuntimeError => e
      e.backtrace[0].should =~ %r{spec/unit/blueprint_spec.rb:#{__LINE__ - 4}:in blueprint 'error'}
    end
  end

  describe "building" do
    describe "build count" do
      it "should increase build count" do
        lambda {
          blueprint.build(stage)
        }.should change(blueprint, :uses).by(1)
      end

      it "should not increase build count if blueprint was already built" do
        blueprint.build(stage)
        lambda {
          blueprint.build(stage, false)
        }.should_not change(blueprint, :uses)
      end
    end

    it "should copy instance variables to container" do
      result = mock
      blueprint { @bl = result }.build(stage)
      stage.instance_variable_get(:@bl).should == result
    end

    describe "auto set variable" do
      it "should be set" do
        blueprint.build(stage)
        stage.instance_variable_get(:@blueprint).should == mock1
      end

      it "should not be set if blueprint defines same variable" do
        result = mock
        blueprint do
          @blueprint = result
          :false_result
        end.build(stage)
        stage.instance_variable_get(:@blueprint).should == result
      end

      it "should reset auto variable" do
        blueprint.build(stage)
        stage.instance_variable_set(:@blueprint, :false_result)
        blueprint.build(stage, false)
        stage.instance_variable_get(:@blueprint).should == mock1
      end
    end

    it "should allow passing options" do
      (result = mock).expects(:options=).with(:option => 'value')
      blueprint2 { result.options = options }.build(stage, true, :option => 'value')
    end

    it "should include attributes for blueprint" do
      (result = mock).expects(:attributes=).with(:option => 'value')
      blueprint2 { result.attributes = attributes }.attributes(:option => 'value').build(stage)
    end

    it "should automatically build dependencies" do
      blueprint
      blueprint2.depends_on(:blueprint).build(stage)
      blueprint.should be_built
    end
  end

  describe "demolish" do
    before do
      @result = blueprint.build(stage)
      @result.stubs(:destroy)
    end

    it "should allow to demolish blueprint" do
      @result.expects(:destroy)
      blueprint.demolish(stage)
    end

    it "should raise error if blueprint is not built" do
      blueprint.demolish(stage)
      lambda { blueprint.demolish(stage) }.should raise_error(Blueprints::DemolishError)
    end

    it "should set blueprint as not built" do
      blueprint.demolish(stage)
      Blueprints::Namespace.root.executed_blueprints.should_not include(blueprint)
    end

    it "should allow to customize demolishing" do
      @result.expects(:demolish)
      blueprint.demolish { @blueprint.demolish }
      blueprint.demolish(stage)
    end
  end

  describe "updating" do
    before do
      @result = blueprint.build(stage)
    end

    it "should allow building blueprint with different parameters" do
      @result.expects(:blueprint).with(:option => 'value')
      blueprint.build stage, true, :option => 'value'
    end

    it "should allow customizing update block" do
      blueprint.update { @blueprint.update_attributes(options) }
      @result.expects(:update_attributes).with(:option => 'value')
      blueprint.build stage, true, :option => 'value'
    end

    it "should not update if build_once is false" do
      blueprint.build stage, false, :option => 'value'
    end
  end
end
