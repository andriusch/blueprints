require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blueprints::Context do
  subject do
    context_with_attrs_and_deps
  end

  let :child_context do
    Blueprints::Context.new(:parent => subject, :attributes => {:attr3 => 30, :attr2 => 20}, :dependencies => [:dep3, 'dep2'])
  end

  describe "initializing" do
    it "should have attributes and and dependencies merged with parent" do
      child_context.attributes.should == {:attr1 => 1, :attr2 => 20, :attr3 => 30}
      child_context.dependencies.should == [:dep1, :dep2, :dep3]
    end

    it "should return own or parent file" do
      subject.file.should == file
      child_context.file.should == file
    end

    it "should return own or parent namespace" do
      subject.namespace.should == namespace
      child_context.namespace.should == namespace
    end
  end

  describe "with context" do
    it "should allow eval within context" do
      File.expects(:read).with('my_file1').returns('method(1)')
      Blueprints::Context.any_instance.expects(:method).with(1)
      Blueprints::Context.eval_within_context(:file => 'my_file1')
    end

    it "should return context" do
      Blueprints::Context.eval_within_context(:dependencies => [:within_dep]).dependencies.should == [:within_dep]
    end

    it "should instance eval with current context set" do
      Blueprints::Context.any_instance.expects(:method).with(1)
      Blueprints::Context.send(:class_variable_get, :@@chain) << context

      Blueprints::Context.eval_within_context(:dependencies => [:within_dep]) do
        method(1)
        Blueprints::Context.current.dependencies.should == [:within_dep]
      end
      Blueprints::Context.current.should == context
    end
  end

  describe "child contexts" do
    it "should yield and return child context with attributes" do
      yielded_context = nil
      subject.attributes(:attr3 => 3) { yielded_context = self }.should == yielded_context
      yielded_context.should be_instance_of(Blueprints::Context)
      yielded_context.attributes.should == {:attr1 => 1, :attr2 => 2, :attr3 => 3}
    end

    it "should yield and return child context with dependencies" do
      yielded_context = nil
      subject.depends_on('the_dep') { yielded_context = self }.should == yielded_context
      yielded_context.should be_instance_of(Blueprints::Context)
      yielded_context.dependencies.should == [:dep1, :dep2, :the_dep]
    end
  end

  describe "blueprints and namespaces" do
    it "should allow creating blueprint" do
      blueprint = subject.blueprint :blueprint
      blueprint.should be_instance_of(Blueprints::Blueprint)
      blueprint.name.should == :blueprint
      blueprint.instance_variable_get(:@context).should == subject
    end

    it "should allow creating namespace" do
      namespace = subject.namespace :namespace
      namespace.should be_instance_of(Blueprints::Namespace)
      namespace.name.should == :namespace
      namespace.instance_variable_get(:@context).should == subject
    end

    it "should allow creating blueprint inside namespace" do
      bp        = nil
      namespace = subject.namespace(:namespace) { bp = self.blueprint :blueprint }
      bp.namespace.should == namespace
      namespace.children.should == {:blueprint => bp}
    end

    it "should allow creating blueprint with inferred name" do
      blueprint = subject.attributes(:name => 'bp').blueprint
      blueprint.name.should == :bp
    end

    it "should allow setting dependency" do
      dep = context.d(:bp, :option => 'val')
      dep.should be_instance_of(Blueprints::Dependency)
    end

    it "should allow finding blueprint you define" do
      blueprint = subject.blueprint :blueprint
      subject.find(:blueprint).should == blueprint
      subject[:blueprint].should == blueprint
    end
  end
end
