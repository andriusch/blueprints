require 'active_record'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.dirname(__FILE__) + '/../support/active_record/initializer'

describe ActiveRecord::Base do
  subject do
    Tree.blueprint(:name => 'tree')
  end

  it "should allow calling blueprint on associations" do
    fruit = subject.fruits.blueprint(:species => 'fruit')
    fruit.should be_instance_of(Fruit)
    fruit.species.should == 'fruit'
    fruit.tree.should == subject
  end

  describe "association callbacks" do
    after do
      class Tree
        def fruit_after_add(fruit)
        end
      end
    end

    it "should call associations specific callbacks when calling blueprint on association" do
      class Tree
        def fruit_after_add(fruit)
          fruit.average_diameter = -1
        end
      end

      fruit = subject.fruits.blueprint(:species => 'fruit')
      fruit.average_diameter.should == -1
    end

    it "should have fields set in callback" do
      Tree.class_eval do
        define_method(:fruit_after_add) do |fruit|
          fruit.species.should == 'fruit'
        end
      end

      subject.fruits.blueprint(:species => 'fruit')
    end
  end

  describe "defining blueprints" do
    describe "inferring name" do
      it "should infer name from class name" do
        blueprint = nil
        Blueprints::Context.eval_within_context({}) { blueprint = Tree.blueprint :attr => 'val' }
        blueprint.name.should == :tree
      end

      it "should still infer name from name default attributes first" do
        blueprint = nil
        Blueprints::Context.eval_within_context({}) { blueprint = Tree.blueprint :name => 'my_tree' }
        blueprint.name.should == :my_tree
      end
    end
  end
end
