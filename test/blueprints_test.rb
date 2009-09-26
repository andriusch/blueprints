require File.dirname(__FILE__) + '/test_helper'

class BlueprintsTest < ActiveSupport::TestCase
  context "scenario files" do
    should "be loaded from specified dirs" do
      assert(Blueprints::PLAN_FILES == ["blueprint.rb", "blueprint/*.rb", "blueprints.rb", "blueprints/*.rb", "spec/blueprint.rb", "spec/blueprint/*.rb", "spec/blueprints.rb", "spec/blueprints/*.rb", "test/blueprint.rb", "test/blueprint/*.rb", "test/blueprints.rb", "test/blueprints/*.rb"]   )
    end
  end

  context "with apple scenario" do
    setup do
      build :apple
    end

    should "create @apple" do
      assert(!(@apple.nil?))
    end

    should "create Fruit @apple" do
      assert(@apple.instance_of?(Fruit))
    end

    should "not create @banana" do
      assert(@banana.nil?)
    end

    should "have correct species" do
      assert(@apple.species == 'apple')
    end
  end

  context "with bananas_and_apples scenario" do
    setup do
      build :bananas_and_apples
    end

    should "have correct @apple species" do
      assert(@apple.species == 'apple')
    end

    should "have correct @banana species" do
      assert(@banana.species == 'banana')
    end
  end

  context "with fruit scenario" do
    setup do
      build :fruit
    end

    should "have 2 fruits" do
      assert(@fruit.size == 2)
    end

    should "have an @apple" do
      assert(@apple.species == 'apple')
    end

    should "have an @orange" do
      assert(@orange.species == 'orange')
    end

    should "have no @banana" do
      assert(@banana.nil?)
    end
  end

  context 'with preloaded cherry scenario' do
    should "have correct size after changed by second test" do
      assert(@cherry.average_diameter == 3)
      @cherry.update_attribute(:average_diameter, 1)
      assert(@cherry.average_diameter == 1)
    end

    should "have correct size" do
      assert(@cherry.average_diameter == 3)
      @cherry.update_attribute(:average_diameter, 5)
      assert(@cherry.average_diameter == 5)
    end

    should "create big cherry" do
      assert(@big_cherry.species == 'cherry')
    end
  end

  context 'demolish' do
    setup do
      build :apple
    end

    should "clear scenarios when calling demolish" do
      demolish
      assert(Fruit.count == 0)
    end

    should "clear only tables passed" do
      Tree.create!(:name => 'oak')
      demolish :fruits
      assert(Tree.count == 1)
      assert(Fruit.count == 0)
    end

    should "mark scenarios as undone when passed :undone option" do
      build :fruit
      demolish :undo => [:apple]
      assert(Fruit.count == 0)
      build :fruit
      assert(Fruit.count == 1)
    end

    should "mark all scenarios as undone when passed :undone option as :all" do
      build :fruit
      demolish :undo => :all
      assert(Fruit.count == 0)
      build :fruit
      assert(Fruit.count == 2)
    end

    should "raise error when not executed scenarios passed to :undo option" do
      assert_raise(ArgumentError) do
        demolish :undo => :orange
      end
    end
  end

  context 'delete policies' do
    setup do
      Blueprints::Plan.plans.expects(:empty?).returns(true)
      Blueprints.expects(:load_scenarios_files).with(Blueprints::PLAN_FILES)
      Blueprints::Plan.expects(:prebuild).with(nil)
    end

    should "allow using custom delete policy" do
      ActiveRecord::Base.connection.expects(:delete).with("TRUNCATE fruits")
      ActiveRecord::Base.connection.expects(:delete).with("TRUNCATE trees")

      Blueprints.load(:delete_policy => :truncate)
    end

    should "default to :delete policy if unexisting policy given" do
      ActiveRecord::Base.connection.expects(:delete).with("DELETE FROM fruits")
      ActiveRecord::Base.connection.expects(:delete).with("DELETE FROM trees")

      Blueprints.load(:delete_policy => :ukndown)
    end
  end

  context 'with many apples scenario' do
    setup do
      build :many_apples, :cherry, :cherry_basket
    end

    should "create only one apple" do
      assert(Fruit.all(:conditions => 'species = "apple"').size == 1)
    end

    should "create only two cherries even if they were preloaded" do
      assert(Fruit.all(:conditions => 'species = "cherry"').size == 2)
    end

    should "contain cherries in basket if basket is loaded in test and cherries preloaded" do
      assert(@cherry_basket == [@cherry, @big_cherry])
    end
  end

  context 'transactions' do
    setup do
      build :apple
    end

    should "drop only inner transaction" do
      assert(!(@apple.reload.nil?))
      begin
        ActiveRecord::Base.transaction do
          f = Fruit.create(:species => 'orange')
          assert(!(f.reload.nil?))
          raise 'some error'
        end
      rescue
      end
      assert(!(@apple.reload.nil?))
      assert(Fruit.find_by_species('orange').nil?)
    end
  end

  context 'errors' do
    should 'raise ScenarioNotFoundError when scenario could not be found' do
      assert_raise(Blueprints::PlanNotFoundError, "Plan(s) not found 'not_existing'") do
        build :not_existing
      end
    end
    
    should 'raise ScenarioNotFoundError when scenario parent could not be found' do
      assert_raise(Blueprints::PlanNotFoundError, "Plan(s) not found 'not_existing'") do
        build :parent_not_existing
      end
    end

    should 'raise TypeError when scenario name is not symbol or string' do
      assert_raise(TypeError, "Pass plan names as strings or symbols only, cannot build plan 1") do
        Blueprints::Plan.new(1)
      end
    end
  end

#describe "with pitted namespace" do
#  before do
#    Hornsby.build('pitted:peach').copy_ivars(self)
#  end

#  it "should have @peach" do
#    @peach.species.should == 'peach'
#  end
#end
end

