require File.dirname(__FILE__) + '/spec_helper'

describe Blueprints::Configuration do
  before do
    @config = Blueprints::Configuration.new
  end

  it "should have filename with default value" do
    @config.filename.should == ["blueprint.rb", "blueprint/*.rb", "spec/blueprint.rb", "spec/blueprint/*.rb", "test/blueprint.rb", "test/blueprint/*.rb"]
  end

  it "should have correct attribute values" do
    @config.orm.should == :active_record
    @config.prebuild.should == []
    @config.transactions.should be_true
    @config.root.should be_nil
  end

  it "should use RAILS_ROOT for root if it's defined" do
    Object::RAILS_ROOT = 'rails/root'
    Blueprints::Configuration.new.root.should == 'rails/root'
    Object.send(:remove_const, :RAILS_ROOT)
  end

  it "should allow to set only supported orm" do
    Blueprints::Configuration::SUPPORTED_ORMS.should == [nil, :active_record]
    @config.orm = nil
    @config.orm.should be_nil

    lambda {
      @config.orm = :not_existing
    }.should raise_error(ArgumentError, 'Unsupported ORM :not_existing. Blueprints supports only nil, :active_record')
  end
end
