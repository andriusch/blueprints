require 'active_record'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.dirname(__FILE__) + '/../support/active_record/initializer'

describe ActiveRecord::Base do
  it "should allow calling blueprint on associations" do
    tree = Tree.blueprint(:name => 'tree')
    fruit = tree.fruits.blueprint(:species => 'fruit')
    fruit.should be_instance_of(Fruit)
    fruit.species.should == 'fruit'
  end
end
