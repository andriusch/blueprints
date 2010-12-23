require File.dirname(__FILE__) + '/spec_helper'

describe Blueprints::Configuration do
  before do
    @config = Blueprints::Configuration.new
  end

  it "should have filename with default value" do
    @config.filename.should == %w{blueprint.rb blueprint/*.rb spec/blueprint.rb spec/blueprint/*.rb test/blueprint.rb test/blueprint/*.rb}.collect do |f|
      Pathname.new(f)
    end
  end

  it "should have correct attribute values" do\
    @config.prebuild.should == []
    @config.transactions.should be_true
    @config.root.should == Pathname.pwd
  end

  it "should use Rails root for root if it's defined" do
    module Rails
      def self.root
        Pathname.new('rails/root')
      end
    end
    Blueprints::Configuration.new.root.should == Pathname.new('rails/root')
    Object.send(:remove_const, :Rails)
  end

  it "should set root to pathname" do
    @config.root = "root"
    @config.root.should == Pathname.new("root")
  end

  it "should automatically set filename to array of path names" do
    @config.filename = "my_file.rb"
    @config.filename.should == [Pathname.new("my_file.rb")]
  end

  describe "default attributes" do
    it "should be name by default" do
      @config.default_attributes.should == [:name]
    end

    it "should automatically convert them to array" do
      @config.default_attributes = :id
      @config.default_attributes.should == [:id]
    end
  end
end
