require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::Dependency do
  before do
    Blueprints::RootNamespace.root.context.instance_eval do
      @value = :value
    end

    mock = @mock
    @value = value = Mocha::Mockery.instance.unnamed_mock
    @blueprint = Blueprints::Blueprint.new(:blueprint, __FILE__) do
      @value = value
      options.present? ? options : mock
    end
  end

  it "should allow getting instance variable value" do
    Blueprints::Dependency.new(:blueprint).value.should == @mock
  end

  it "should allow getting another instance variable" do
    Blueprints::Dependency.new(:blueprint, :value).value.should == @value
  end

  it "should allow passing options for building" do
    Blueprints::Dependency.new(:blueprint, :option => 'value').value.should == {:option => 'value'} 
  end
end
