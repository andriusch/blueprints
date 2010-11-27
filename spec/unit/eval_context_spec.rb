require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::EvalContext do
  subject do
    Blueprints::EvalContext.new
  end

  it "should contain no instance variables" do
    subject.instance_variables.should == []
  end

  describe "instance variables" do
    it "should allow copying variables to other context" do
      subject.instance_variable_set(:@var, :value)
      subject.copy_instance_variables(context = Object.new)
      context.instance_variables.collect(&:to_sym).should == [:@var]
      context.instance_variable_get(:@var).should == :value
    end
  end

  describe "instance eval" do
    subject do
      Blueprints::EvalContext.new
    end

    it "should allow to access to options" do
      subject.instance_eval(context, :option => 'value') do
        options.should == {:option => 'value'}
      end
    end

    it "should allow to access to attributes" do
      subject.instance_eval(context_with_attrs_and_deps, :option => 'value') do
        attributes.should == {:option => 'value', :attr1 => 1, :attr2 => 2}
      end
    end

    it "should normalize options and attributes" do
      blueprint.build(subject)
      subject.instance_variable_set(:@value, 2)
      context = Blueprints::Context.new(:attributes => {:attr => Blueprints::Dependency.new(:blueprint)})

      subject.instance_eval(context, :attr2 => lambda { @value + 2 }, :attr3 => :value) do
        options.should == {:attr2 => 4, :attr3 => :value}
        attributes.should == {:attr => @blueprint, :attr2 => 4, :attr3 => :value}
      end
    end
  end

  describe "build" do
    it "should allow building blueprint" do
      blueprint
      subject.build(:blueprint).should == mock1
    end
  end
end
