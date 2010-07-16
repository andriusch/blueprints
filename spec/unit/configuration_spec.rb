require File.dirname(__FILE__) + '/spec_helper'

describe Blueprints::Configuration do
  before do
    @config = Blueprints::Configuration.new
  end

  it "should have filename with default value" do
    @config.filename.should == ["blueprint.rb", "blueprint/*.rb", "spec/blueprint.rb", "spec/blueprint/*.rb", "test/blueprint.rb", "test/blueprint/*.rb"].collect do |f|
      Pathname.new(f)
    end
  end

  it "should have correct attribute values" do
    @config.orm.should == :active_record
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

  it "should allow to set only supported orm" do
    Blueprints::Configuration::SUPPORTED_ORMS.should == [nil, :active_record]
    @config.orm = nil
    @config.orm.should be_nil

    lambda {
      @config.orm = :not_existing
    }.should raise_error(ArgumentError, 'Unsupported ORM :not_existing. Blueprints supports only nil, :active_record')
  end

  it "should set root to pathname" do
    @config.root = "root"
    @config.root.should == Pathname.new("root")
  end

  it "should automatically set filename to array of path names" do
    @config.filename = "my_file.rb"
    @config.filename.should == [Pathname.new("my_file.rb")]
  end
end
