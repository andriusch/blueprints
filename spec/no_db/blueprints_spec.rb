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
      @big_cherry.size = 15
    end

    it "big cherry should have size of 10 even if it was changed in test above" do
      @big_cherry.size.should == 10
      @big_cherry.size = 13
    end
  end

  describe "build per describe" do
    build_blueprint :cherry

    it "should have cherry" do
      @cherry.should_not be_nil
    end

    it "should have correct cherry species" do
      @cherry.species.should == 'cherry'
    end
  end
end
