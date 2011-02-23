require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::Blueprint do
  it "should rewrite trace" do
    context = Blueprints::Context.new(:file => __FILE__)
    error_blueprint = Blueprints::Blueprint.new(:error, context) { raise 'error' }
    begin
      error_blueprint.build(stage)
    rescue RuntimeError => e
      e.backtrace[0].should == "While building blueprint 'error'"
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
          blueprint.build(stage, :rebuild => true)
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
        blueprint.build(stage, :rebuild => true)
        stage.instance_variable_get(:@blueprint).should == mock1
      end
    end

    describe 'options, attributes and dependencies' do
      it "should allow passing options" do
        (result = mock).expects(:options=).with(:option => 'value')
        blueprint2 { result.options = options }.build(stage, :options => {:option => 'value'})
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

      it "should not overwrite options and attributes methods" do
        def stage.options
          :options
        end

        def stage.attributes
          :attributes
        end

        blueprint2.build(stage, :options => {:option => 'value'})

        stage.options.should == :options
        stage.attributes.should == :attributes
      end

      it "should normalize options and attributes" do
        blueprint
        stage.instance_variable_set(:@value, 2)
        blueprint2 { [options, attributes] }.attributes(:attr => Blueprints::Dependency.new(:blueprint))
        options, attributes = blueprint2.build(stage, :options => {:attr2 => lambda { @value + 2 }, :attr3 => :value})

        options.should == {:attr2 => 4, :attr3 => :value}
        attributes.should == {:attr => mock1, :attr2 => 4, :attr3 => :value}
      end

      it "should return normalized attributes" do
        blueprint2
        blueprint.attributes(:attr => Blueprints::Dependency.new(:blueprint2))
        blueprint.normalized_attributes(stage, :attr2 => 1).should == {:attr => mock1, :attr2 => 1}
      end
    end

    describe "strategies" do
      it "should allow defining different strategies" do
        new_result = mock('new_result')
        blueprint.blueprint(:new) { new_result }
        blueprint.build(stage, :strategy => 'new').should == new_result
      end

      it "should return blueprint itself" do
        blueprint.blueprint(:new) { 1 }.should == blueprint
      end
    end

    describe "on error" do
      it "should allow rebuilding blueprint" do
        blueprint do
          unless @is_built
            @is_built = true
            raise 'Failure'
          end
          :success
        end

        expect {
          blueprint.build(stage)
        }.to raise_error
        blueprint.build(stage).should == :success
      end

      it "should restore overwritten methods" do
        def stage.options
          :options
        end

        expect {
          blueprint { raise 'error' }.build(stage)
        }.to raise_error
        stage.options.should == :options
      end
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
      blueprint.build stage, :options => {:option => 'value'}
    end

    it "should allow customizing update block" do
      blueprint.update { @blueprint.update_attributes(options) }
      @result.expects(:update_attributes).with(:option => 'value')
      blueprint.build stage, :options => {:option => 'value'}
    end

    it "should not update if build_once is false" do
      blueprint.build stage, :options => {:option => 'value'}, :rebuild => true
    end
  end

  describe "extending" do
    before do
      blueprint
    end

    it "should allow extending with nothing" do
      blueprint2.extends(:blueprint)
    end
  end
end
