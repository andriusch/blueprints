require File.join(File.dirname(__FILE__), 'spec_helper')

describe Blueprints do
  it "should build cherry blueprint" do
    build :cherry
    @cherry.should_not be_nil
    @cherry.should be_instance_of(Fruit)
    @cherry.species.should == 'cherry'
  end

  it "should not build cherry if not asked" do
    @cherry.should == nil
  end

  describe "prebuilt blueprints" do
    it "big cherry should have size of 10 even if it was changed in test below" do
      @big_cherry.size.should == 10
      @big_cherry.blueprint :size => 15
    end

    it "big cherry should have size of 10 even if it was changed in test above" do
      @big_cherry.size.should == 10
      @big_cherry.blueprint :size => 13
    end
  end

  it "should allow shortened forms of blueprint" do
    build :apple
    @apple.should_not be_nil
    @apple.species.should == 'apple'
    @apple.size.should == 3
  end
end
