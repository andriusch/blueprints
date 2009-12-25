require File.dirname(__FILE__) + '/spec_helper'

describe Blueprints do
  describe "constants" do
    it "should be loaded from specified dirs" do
      Blueprints::PLAN_FILES.should == ["blueprint.rb", "blueprint/*.rb", "spec/blueprint.rb", "spec/blueprint/*.rb", "test/blueprint.rb", "test/blueprint/*.rb"]
    end

    it "should support required ORMS" do
      Blueprints.supported_orms.should =~ [:active_record, :none]
    end
  end

  it "should return result of built scenario when calling build" do
    fruit = build :fruit
    fruit.should == @fruit

    apple = build :apple
    apple.should == @apple
  end

  describe "with apple scenario" do
    before do
      build :apple
    end

    it "should create @apple" do
      @apple.should_not be_nil
    end

    it "should create Fruit @apple" do
      @apple.should be_instance_of(Fruit)
    end

    it "should not create @banana" do
      @banana.should be_nil
    end

    it "should have correct species" do
      @apple.species.should == 'apple'
    end
  end

  describe "with bananas_and_apples scenario" do
    before do
      build :bananas_and_apples
    end

    it "should have correct @apple species" do
      @apple.species.should == 'apple'
    end

    it "should have correct @banana species" do
      @banana.species.should == 'banana'
    end
  end

  describe "with fruit scenario" do
    before do
      build :fruit
    end

    it "should have 2 fruits" do
      @fruit.should have(2).items
    end

    it "should have an @apple" do
      @apple.species.should == 'apple'
    end

    it "should have an @orange" do
      @orange.species.should == 'orange'
    end

    it "should have no @banana" do
      @banana.should be_nil
    end
  end

  describe 'with preloaded cherry scenario' do
    it "should have correct size after changed by second test" do
      @cherry.average_diameter.should == 3
      @cherry.update_attribute(:average_diameter, 1)
      @cherry.average_diameter.should == 1
    end

    it "should have correct size" do
      @cherry.average_diameter.should == 3
      @cherry.update_attribute(:average_diameter, 5)
      @cherry.average_diameter.should == 5
    end

    it "should create big cherry" do
      @big_cherry.species.should == 'cherry'
    end
  end

  describe 'demolish' do
    before do
      build :apple
    end

    it "should clear scenarios when calling demolish" do
      demolish
      Fruit.count.should == 0
    end

    it "should clear only tables passed" do
      Tree.create!(:name => 'oak')
      demolish :fruits
      Tree.count.should == 1
      Fruit.count.should == 0
    end

    it "should mark scenarios as undone when passed :undone option" do
      build :fruit
      demolish :undo => [:apple]
      Fruit.count.should == 0
      build :fruit
      Fruit.count.should == 1
    end

    it "should mark all scenarios as undone when passed :undone option as :all" do
      build :fruit
      demolish :undo => :all
      Fruit.count.should == 0
      build :fruit
      Fruit.count.should == 2
    end

    it "should raise error when not executed scenarios passed to :undo option" do
      lambda {
        demolish :undo => :orange
      }.should raise_error(Blueprints::PlanNotFoundError, "Plan/namespace not found 'orange'")
    end
  end

  describe 'delete policies' do
    before do
      Blueprints::Namespace.root.stubs(:empty?).returns(true)
      Blueprints.stubs(:load_scenarios_files).with(Blueprints::PLAN_FILES)
      Blueprints::Namespace.root.stubs(:prebuild).with(nil)
    end

    after do
      Blueprints.send(:class_variable_set, :@@delete_policy, nil)
    end

    it "should allow using custom delete policy" do
      ActiveRecord::Base.connection.expects(:delete).with("TRUNCATE fruits")
      ActiveRecord::Base.connection.expects(:delete).with("TRUNCATE trees")

      Blueprints.load(:delete_policy => :truncate)
    end

    it "should raise an error if unexisting delete policy given" do
      lambda {
        Blueprints.load(:delete_policy => :unknown)
      }.should raise_error(ArgumentError, 'Unknown delete policy unknown')
    end
  end

  describe 'with many apples scenario' do
    before do
      build :many_apples, :cherry, :cherry_basket
    end

    it "should create only one apple" do
      Fruit.all(:conditions => 'species = "apple"').size.should == 1
    end

    it "should create only two cherries even if they were preloaded" do
      Fruit.all(:conditions => 'species = "cherry"').size.should == 2
    end

    it "should contain cherries in basket if basket is loaded in test and cherries preloaded" do
      @cherry_basket.should == [@cherry, @big_cherry]
    end
  end

  describe 'transactions' do
    before do
      build :apple
    end

    it "should drop only inner transaction" do
      @apple.reload.should_not be_nil
      begin
        ActiveRecord::Base.transaction do
          f = Fruit.create(:species => 'orange')
          f.reload.should_not be_nil
          raise 'some error'
        end
      rescue
      end
      @apple.reload.should_not be_nil
      Fruit.find_by_species('orange').should be_nil
    end
  end

  describe 'errors' do
    it 'should raise ScenarioNotFoundError when scenario could not be found' do
      lambda {
        build :not_existing
      }.should raise_error(Blueprints::PlanNotFoundError, "Plan/namespace not found 'not_existing'")
    end

    it 'should raise ScenarioNotFoundError when scenario parent could not be found' do
      lambda {
        build :parent_not_existing
      }.should raise_error(Blueprints::PlanNotFoundError, "Plan/namespace not found 'not_existing'")
    end

    it 'should raise TypeError when scenario name is not symbol or string' do
      lambda {
        Blueprints::Plan.new(1)
      }.should raise_error(TypeError, "Pass plan names as strings or symbols only, cannot build plan 1")
    end

    it "should raise ArgumentError when unknown ORM specified" do
      Blueprints::Namespace.root.expects(:empty?).returns(true)
      lambda {
        Blueprints.load(:orm => :unknown)
      }.should raise_error(ArgumentError, "Unsupported ORM unknown. Blueprints supports only #{Blueprints.supported_orms.join(', ')}")
    end
  end

  describe 'with active record blueprints extensions' do
    it "should build oak correctly" do
      build :oak
      @oak.should_not be_nil
      @oak.name.should == 'Oak'
      @oak.size.should == 'large'
    end

    it "should build pine correctly" do
      build :pine
      @the_pine.should_not be_nil
      @the_pine.name.should == 'Pine'
      @the_pine.size.should == 'medium'
    end

    it "should associate acorn with oak correctly" do
      build :acorn
      @oak.should_not be_nil
      @acorn.should_not be_nil
      @acorn.tree.should == @oak
    end

    it "should allow updating object using blueprint method" do
      build :oak
      @oak.blueprint(:size => 'updated')
      @oak.reload.size.should == 'updated'
    end

    it "should automatically merge passed options" do
      build :oak, :size => 'optional'
      @oak.name.should == 'Oak'
      @oak.size.should == 'optional'
    end
  end

  describe "with pitted namespace" do
    it "should allow building namespaced scenarios" do
      build 'pitted.peach_tree'
      @pitted_peach_tree.name.should == 'pitted peach tree'
    end

    it "should allow adding dependencies from same namespace" do
      build 'pitted.peach'
      @pitted_peach.species.should == 'pitted peach'
      @pitted_peach_tree.should_not be_nil
    end

    it "should allow adding dependencies from root namespace" do
      build 'pitted.acorn'
      @pitted_acorn.species.should == 'pitted acorn'
      @oak.should_not be_nil
    end

    it "should allow building whole namespace" do
      build :pitted
      @pitted_peach_tree.should_not be_nil
      @pitted_peach.should_not be_nil
      @pitted_acorn.should_not be_nil
      @pitted_red_apple.should_not be_nil
      @pitted.sort_by(&:id).should == [@pitted_peach_tree, @pitted_peach, @pitted_acorn, [@pitted_red_apple]].sort_by(&:id)
    end

    describe "with red namespace" do
      it "should allow building blueprint with same name in different namespaces" do
        build :apple, 'pitted.red.apple'
        @apple.species.should == 'apple'
        @pitted_red_apple.species.should == 'pitted red apple'
      end

      it "should load dependencies when building namespaced blueprint if parent namespaces have any" do
        build 'pitted.red.apple'
        @the_pine.should_not be_nil
        @orange.should_not be_nil
      end

      it "should allow building nested namespaces scenarios" do
        build 'pitted.red.apple'
        @pitted_red_apple.species.should == 'pitted red apple'
      end
    end
  end

  describe 'extra parameters' do
    it "should allow passing extra parameters when building" do
      build :apple_with_params, :average_diameter => 14
      @apple_with_params.average_diameter.should == 14
      @apple_with_params.species.should == 'apple'
    end

    it "should allow set options to empty hash if no parameters are passed" do
      build :apple_with_params
      @apple_with_params.average_diameter.should == nil
      @apple_with_params.species.should == 'apple'
    end
  end
end

