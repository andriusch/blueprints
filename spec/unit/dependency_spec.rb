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
    Blueprints::Dependency.new(:blueprint).blueprint_value.should == @mock
  end

  it "should allow getting another instance variable" do
    Blueprints::Dependency.new(:blueprint, :value).blueprint_value.should == @value
  end

  it "should allow passing options for building" do
    Blueprints::Dependency.new(:blueprint, :option => 'value').blueprint_value.should == {:option => 'value'}
  end

  it "should record all missing methods" do
    dependency = Blueprints::Dependency.new(:blueprint)
    dependency.method1.method2(1).method3 {|val| val.method4 }

    @mock.expects(:method1).with().returns(mock1 = mock)
    mock1.expects(:method2).with(1).returns(mock2 = mock)
    mock2.expects(:method3).with().yields(mock(:method4 => true)).returns(result = mock)

    dependency.blueprint_value.should == result
  end

  it "should record to_s, id and other standard methods" do
    dependency = Blueprints::Dependency.new(:blueprint)
    dependency.id.to_s

    @mock.expects(:id).returns(mock1 = mock)
    mock1.expects(:to_s).returns(result = mock)

    dependency.blueprint_value.should == result
  end
end
