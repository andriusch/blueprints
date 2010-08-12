require 'active_record'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'spec/active_record/fixtures/fruit'
require 'spec/active_record/fixtures/tree'

databases = YAML::load(IO.read("spec/active_record/fixtures/database.yml"))
db_info = databases[ENV["DB"] || "test"]
ActiveRecord::Base.establish_connection(db_info)

describe ActiveRecord::Base do
  it "should allow calling blueprint on associations" do
    tree = Tree.blueprint(:name => 'tree')
    fruit = tree.fruits.blueprint(:species => 'fruit')
    fruit.should be_instance_of(Fruit)
    fruit.species.should == 'fruit'
  end
end
