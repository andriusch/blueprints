require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::Dependency do
  before do
    Blueprints::RootNamespace.root.context.instance_eval do
      @value = :value
    end
    options_blueprint
  end

  it "should allow getting instance variable value" do
    Blueprints::Dependency.new(:options_blueprint).value.should == mock1
  end

  it "should allow getting another instance variable" do
    Blueprints::Dependency.new(:options_blueprint, :value).value.should == mock2
  end

  it "should allow passing options for building" do
    Blueprints::Dependency.new(:options_blueprint, :option => 'value').value.should == {:option => 'value'}
  end

  it "should record all missing methods" do
    dependency = Blueprints::Dependency.new(:options_blueprint)
    dependency.method1.method2(1).method3 {|val| val.method4 }

    mock1.expects(:method1).with().returns(mock2 = mock)
    mock2.expects(:method2).with(1).returns(mock3 = mock)
    mock3.expects(:method3).with().yields(mock(:method4 => true)).returns(result = mock)

    dependency.value.should == result
  end
end
