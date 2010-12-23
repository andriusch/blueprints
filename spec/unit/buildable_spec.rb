require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::Buildable do
  it "should inspect buildable nicely" do
    namespace_blueprint.attributes(:attr => 'value').depends_on(:dependency)
    namespace_blueprint.inspect.should == %q(<#Blueprints::Blueprint name: "namespace.blueprint", attributes: {:attr=>"value"}, dependencies: [:dependency]>)
  end

  describe "name" do
    after do
      Blueprints.config.default_attributes = :name
    end

    it 'should raise TypeError when scenario name is not symbol or string' do
      lambda {
        Blueprints::Blueprint.new([], context)
      }.should raise_error(TypeError, "Pass blueprint names as strings or symbols only, cannot define blueprint []")
    end

    it "should return full name" do
      namespace_blueprint.full_name.should == 'namespace.blueprint'
    end

    describe "inferring" do
      it "should infer name using default attributes" do
        Blueprints::Buildable.new(nil, context.attributes(:name => 'inferred_name')).name.should == :inferred_name
      end

      it "should infer name from third default attribute" do
        Blueprints.config.default_attributes = :name, :to_s, :id
        Blueprints::Buildable.new(nil, context.attributes(:id => 'third')).name.should == :third
      end

      it "should parameterize infered name" do
        Blueprints::Buildable.new(nil, context.attributes(:name => 'my blueprint')).name.should == :my_blueprint
      end

      it "should raise error if name can't be inferred" do
        lambda {
          Blueprints::Buildable.new(nil, context.attributes(:id => 'third')).name.should == :third
        }.should raise_error(TypeError, "Pass blueprint names as strings or symbols only, cannot define blueprint nil")
      end
    end
  end
end
