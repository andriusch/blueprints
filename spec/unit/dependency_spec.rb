require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::Dependency do
  before do
    stage.instance_variable_set(:@value, :value)
    options_blueprint
  end

  let :stage do
    Blueprints::Namespace.root.eval_context
  end

  def value(dep)
    stage.instance_eval(context, {}, &dep)
  end

  it "should allow getting instance variable value" do
    value(Blueprints::Dependency.new(:options_blueprint)).should == mock1
  end

  it "should allow getting another instance variable" do
    value(Blueprints::Dependency.new(:options_blueprint, :value)).should == mock2
  end

  it "should replace . in instance variable name with _" do
    namespace_blueprint
    value(Blueprints::Dependency.new(:'namespace.blueprint')).should == mock1
  end

  it "should allow passing options for building" do
    value(Blueprints::Dependency.new(:options_blueprint, :option => 'value')).should == {:option => 'value'}
  end

  it "should record all missing methods" do
    dependency = Blueprints::Dependency.new(:options_blueprint)
    dependency.method1.method2(1).method3 {|val| val.method4 }

    mock1.expects(:method1).with().returns(mock2 = mock)
    mock2.expects(:method2).with(1).returns(mock3 = mock)
    mock3.expects(:method3).with().yields(mock(:method4 => true)).returns(result = mock)

    value(dependency).should == result
  end

  it "should record to_s, id and other standard methods" do
    dependency = Blueprints::Dependency.new(:options_blueprint)
    dependency.id.to_s

    @mock.expects(:id).returns(mock1 = mock)
    mock1.expects(:to_s).returns(result = mock)

    value(dependency).should == result
  end
end
