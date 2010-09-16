require File.dirname(__FILE__) + '/test_helper'

class BlueprintsTest < ActiveSupport::TestCase
  should "return result of built scenario when calling build" do
    fruit = build :fruit
    assert(fruit == @fruit)

    apple = build :apple
    assert(apple == @apple)
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
      demolish :apple
      assert(!Fruit.all.include?(@apple))
      build :apple
      assert(Fruit.last == @apple)
    end

    should "overwrite auto created instance variable with another auto created one" do
      build :acorn => {:average_diameter => 3}
      demolish :acorn
      assert(@acorn.average_diameter == 3)

      build :acorn => {:average_diameter => 5}
      assert(@acorn.average_diameter == 5)
    end
  end

  context "updating" do
    should "allow updating prebuilt blueprints" do
      build :big_cherry => {:species => 'updated cherry'}
      assert(@big_cherry.species == 'updated cherry')
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
      assert_raise(Blueprints::BlueprintNotFoundError) do
        build :not_existing
      end
    end

    should 'raise ScenarioNotFoundError when scenario parent could not be found' do
      assert_raise(Blueprints::BlueprintNotFoundError) do
        build :parent_not_existing
      end
    end
  end

  context 'with active record blueprints extensions' do
    should "build oak correctly" do
      build :oak
      assert(!(@oak.nil?))
      assert(@oak.name == 'Oak')
      assert(@oak.size == 'large')
    end

    should "build pine correctly" do
      build :pine
      assert(!(@the_pine.nil?))
      assert(@the_pine.name == 'Pine')
      assert(@the_pine.size == 'medium')
    end

    should "associate acorn with oak correctly" do
      build :acorn
      assert(!(@oak.nil?))
      assert(!(@acorn.nil?))
      assert(@acorn.tree == @oak)
    end

    should "allow updating object using blueprint method" do
      build :oak
      @oak.blueprint(:size => 'updated')
      assert(@oak.reload.size == 'updated')
    end

    should "normalize attributes when updating with blueprint method" do
      build :cherry, :oak
      @cherry.blueprint(:tree => d(:oak))
      assert(@cherry.tree == @oak)
    end

    should "automatically merge passed options" do
      build :oak => {:size => 'optional'}
      assert(@oak.name == 'Oak')
      assert(@oak.size == 'optional')
    end

    should "allow to pass array of hashes to blueprint method" do
      Fruit.create
      fruits = Fruit.blueprint([{:species => 'fruit1'}, {:species => 'fruit2'}])
      assert(fruits.collect(&:species) == %w{fruit1 fruit2})
    end

    should "allow to build oak without attributes" do
      build :oak_without_attributes
      assert(@oak_without_attributes.instance_of?(Tree))
    end
  end

  context "with pitted namespace" do
    should "allow building namespaced scenarios" do
      build 'pitted.peach_tree'
      assert(@pitted_peach_tree.name == 'pitted peach tree')
    end

    should "allow adding dependencies from same namespace" do
      build 'pitted.peach'
      assert(@pitted_peach.species == 'pitted peach')
      assert(!(@pitted_peach_tree.nil?))
    end

    should "allow adding dependencies from root namespace" do
      build 'pitted.acorn'
      assert(@pitted_acorn.species == 'pitted acorn')
      assert(!(@oak.nil?))
    end

    should "allow building whole namespace" do
      build :pitted
      assert(!(@pitted_peach_tree.nil?))
      assert(!(@pitted_peach.nil?))
      assert(!(@pitted_acorn.nil?))
      assert(!(@pitted_red_apple.nil?))
      assert_similar(@pitted, [@pitted_peach_tree, @pitted_peach, @pitted_acorn, [@pitted_red_apple]])
      assert(build(:pitted) == @pitted)
    end

    context "with red namespace" do
      should "allow building blueprint with same name in different namespaces" do
        build :apple, 'pitted.red.apple'
        assert(@apple.species == 'apple')
        assert(@pitted_red_apple.species == 'pitted red apple')
      end

      should "load dependencies when building namespaced blueprint if parent namespaces have any" do
        build 'pitted.red.apple'
        assert(!(@the_pine.nil?))
        assert(!(@orange.nil?))
      end

      should "allow building nested namespaces scenarios" do
        build 'pitted.red.apple'
        assert(@pitted_red_apple.species == 'pitted red apple')
      end
    end
  end

  context 'extra parameters' do
    should "allow passing extra parameters when building" do
      build :apple_with_params => {:average_diameter => 14}
      assert(@apple_with_params.average_diameter == 14)
      assert(@apple_with_params.species == 'apple')
    end

    should "allow set options to empty hash if no parameters are passed" do
      build :apple_with_params
      assert(@apple_with_params.average_diameter == nil)
      assert(@apple_with_params.species == 'apple')
    end

    should "use extra params only on blueprints specified" do
      build :acorn => {:average_diameter => 5}
      assert(@acorn.average_diameter == 5)
    end

    should "allow passing extra params for each blueprint individually" do
      build :acorn => {:average_diameter => 3}, :apple_with_params => {:average_diameter => 2}
      assert(@acorn.average_diameter == 3)
      assert(@apple_with_params.average_diameter == 2)
    end

    should "allow passing options for some blueprints only" do
      assert(build(:acorn, :apple_with_params => {:average_diameter => 2}) == @apple_with_params)
      assert(@acorn.average_diameter == nil)
      assert(@apple_with_params.average_diameter == 2)
    end
  end

  context "extending blueprints" do
    should "allow to call build method inside blueprint body" do
      build :small_acorn
      assert(@small_acorn.average_diameter == 1)
      assert(@small_acorn == @acorn)
    end

    should "not reset options after call to build" do
      build :small_acorn => {:option => 'value'}
      assert(@small_acorn_options == {:option => 'value'})
    end

    should "allow to use shortcut to extend blueprint" do
      build :huge_acorn
      assert(@huge_acorn.average_diameter == 100)
    end

    should "allow extended blueprint be dependency and associated object" do
      build :huge_acorn
      assert(@huge_acorn.tree.size == 'huge')
    end

    should "allow to pass options when building extended blueprint" do
      build :huge_acorn => {:average_diameter => 200}
      assert(@huge_acorn.average_diameter == 200)
    end
  end

  should "allow to build! without checking if it was already built" do
    build! :big_cherry, :big_cherry => {:species => 'not so big cherry'}
    assert(Fruit.count == 4)
    assert(!(Fruit.find_by_species('not so big cherry').nil?))
  end

  context 'attributes' do
    should "allow to extract attributes from blueprint" do
      assert(build_attributes('attributes.cherry') == {:species => 'cherry'})
      assert(build_attributes('attributes.shortened_cherry') == {:species => 'cherry'})
      assert(build_attributes(:big_cherry) == {})
    end

    should "use attributes when building" do
      build 'attributes.cherry'
      assert(@attributes_cherry.species == 'cherry')
    end

    should "automatically merge options to attributes" do
      build 'attributes.cherry' => {:species => 'a cherry'}
      assert(@attributes_cherry.species == 'a cherry')
    end

    should "reverse merge attributes from namespaces" do
      build 'attributes.cherry'
      assert(@attributes_cherry.average_diameter == 10)
    end

    should "return build attributes for dependencies" do
      attrs = build_attributes('attributes.dependent_cherry')
      assert(!(@the_pine.nil?))
      assert(attrs[:tree] == @the_pine)
    end
  end

  should "not fail with circular reference" do
    build :circular_reference
  end

  should "rewrite trace" do
    begin
      build :error
    rescue RuntimeError => e
      assert(e.backtrace[0] == "spec/active_record/blueprint.rb:2:in blueprint 'error'")
    end
  end
end
