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

  it "should call associations specific callbacks when calling blueprint on association" do
    class Tree
      def fruit_after_add(fruit)
        fruit.average_diameter = -1
      end
    end

    fruit = subject.fruits.blueprint(:species => 'fruit')
    fruit.average_diameter.should == -1

    class Tree
      def fruit_after_add(fruit)
      end
    end
  end
end
