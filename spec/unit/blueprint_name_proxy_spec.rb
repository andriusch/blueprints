require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::BlueprintNameProxy do
  subject do
    Blueprints::BlueprintNameProxy.new(:regexp_blueprint, namespace_regexp_blueprint)
  end

  it "should pass matched groups as options" do
    subject.build(stage)
    stage.instance_variable_get(:@namespace_regexp_blueprint).should == {:arg0 => 'blueprint'}
  end

  it "should pass any other options" do
    namespace_regexp_blueprint.expects(:build).with(stage, :options => {:passed => 1, :arg0 => 'blueprint'}, :rebuild => true, :name => :regexp_blueprint)
    subject.build(stage, :options => {:passed => 1}, :rebuild => true)
  end

  it "should allow capturing named groups" do
    if RUBY_VERSION.start_with?('1.9')
      regexp = 'regexp_(?<name>.*)'
      namespace_regexp_blueprint(Regexp.new(regexp))
      subject.build(stage)
      stage.instance_variable_get(:@namespace_regexp_blueprint).should == {:name => 'blueprint'}
    end
  end

  it "should allow demolishing buildable" do
    subject.build(stage).expects(:destroy)
    subject.demolish(stage)
  end
end
