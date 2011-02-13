require File.dirname(__FILE__) + '/spec_helper'

describe Blueprints do
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

  describe "build per describe" do
    unless File.dirname(__FILE__) =~ /test$/
      build_blueprint :apple

      it "should have cherry" do
        @apple.should_not be_nil
      end

      it "should have correct cherry species" do
        @apple.species.should == 'apple'
      end
    end
  end

  describe 'with preloaded cherry scenario' do
    it "should have correct size after changed by second test" do
      @cherry.average_diameter.should == 3
      @cherry.blueprint(:average_diameter => 1)
      @cherry.average_diameter.should == 1
    end

    it "should have correct size" do
      @cherry.average_diameter.should == 3
      @cherry.blueprint(:average_diameter => 5)
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
      demolish :apple
      Fruit.all.should_not include(@apple)
      build :apple
      Fruit.all.should include(@apple)
    end

    it "should overwrite auto created instance variable with another auto created one" do
      build :acorn => {:average_diameter => 3}
      demolish :acorn
      @acorn.average_diameter.should == 3

      build :acorn => {:average_diameter => 5}
      @acorn.average_diameter.should == 5
    end
  end

  describe "updating" do
    it "should allow updating prebuilt blueprints" do
      build :big_cherry => {:species => 'updated cherry'}
      @big_cherry.species.should == 'updated cherry'
    end
  end

  describe 'with many apples scenario' do
    before do
      build :many_apples, :cherry, :cherry_basket
    end

    it "should create only one apple" do
      Fruit.all(:conditions => {:species => "apple"}).size.should == 1
    end

    it "should create only two cherries even if they were preloaded" do
      Fruit.all(:conditions => {:species => "cherry"}).size.should == 2
    end

    it "should contain cherries in basket if basket is loaded in test and cherries preloaded" do
      @cherry_basket.should == [@cherry, @big_cherry]
    end
  end

  describe 'errors' do
    it 'should raise ScenarioNotFoundError when scenario could not be found' do
      lambda {
        build :not_existing
      }.should raise_error(Blueprints::BlueprintNotFoundError)
    end

    it 'should raise ScenarioNotFoundError when scenario parent could not be found' do
      lambda {
        build :parent_not_existing
      }.should raise_error(Blueprints::BlueprintNotFoundError)
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

    it "should normalize attributes when updating with blueprint method" do
      build :cherry, :oak
      build :cherry => {:tree => d(:oak)}
      @cherry.tree.should == @oak
    end

    it "should automatically merge passed options" do
      build :oak => {:size => 'optional'}
      @oak.name.should == 'Oak'
      @oak.size.should == 'optional'
    end

    it "should allow to pass array of hashes to blueprint method" do
      fruits = Fruit.blueprint({:species => 'fruit1'}, {:species => 'fruit2'})
      fruits.collect(&:species).should == %w{fruit1 fruit2}
    end

    it "should allow to build oak without attributes" do
      build :oak_without_attributes
      @oak_without_attributes.should be_instance_of(Tree)
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
      @pitted.should =~ [@pitted_peach_tree, @pitted_peach, @pitted_acorn, [@pitted_red_apple]]
      build(:pitted).should == @pitted
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
      build :apple_with_params => {:average_diameter => 14}
      @apple_with_params.average_diameter.should == 14
      @apple_with_params.species.should == 'apple'
    end

    it "should allow set options to empty hash if no parameters are passed" do
      build :apple_with_params
      @apple_with_params.average_diameter.should == nil
      @apple_with_params.species.should == 'apple'
    end

    it "should use extra params only on blueprints specified" do
      build :acorn => {:average_diameter => 5}
      @acorn.average_diameter.should == 5
    end

    it "should allow passing extra params for each blueprint individually" do
      build :acorn => {:average_diameter => 3}, :apple_with_params => {:average_diameter => 2}
      @acorn.average_diameter.should == 3
      @apple_with_params.average_diameter.should == 2
    end

    it "should allow passing options for some blueprints only" do
      build(:acorn, :apple_with_params => {:average_diameter => 2}).should == @apple_with_params
      @acorn.average_diameter.should == nil
      @apple_with_params.average_diameter.should == 2
    end
  end

  describe "extending blueprints" do
    it "should allow to call build method inside blueprint body" do
      build :small_acorn
      @small_acorn.average_diameter.should == 1
      @small_acorn.should == @acorn
    end

    it "should not reset options after call to build" do
      build :small_acorn => {:option => 'value'}
      @small_acorn_options.should == {:option => 'value'}
    end

    it "should allow to use shortcut to extend blueprint" do
      build :huge_acorn
      @huge_acorn.average_diameter.should == 100
    end

    it "should allow extended blueprint be dependency and associated object" do
      build :huge_acorn
      @huge_acorn.tree.size.should == 'huge'
    end

    it "should allow to pass options when building extended blueprint" do
      build :huge_acorn => {:average_diameter => 200}
      @huge_acorn.average_diameter.should == 200
    end
  end

  describe "build!" do
    it "should allow to building same blueprint again" do
      build! :big_cherry, :big_cherry => {:species => 'not so big cherry'}
      Fruit.count.should == 4
      Fruit.first(:conditions => {:species => 'not so big cherry'}).should_not be_nil
    end

    it "should allow building same blueprint n times" do
      oaks = build! 5, :oak
      oaks.should have(5).items
      oaks.each do |oak|
        oak.should be_instance_of(Tree)
        oak.name.should == 'Oak'
      end
    end
  end

  describe 'attributes' do
    it "should allow to extract attributes from blueprint" do
      build_attributes('attributes.cherry').should == {:species => 'cherry', :average_diameter => 10}
      build_attributes('attributes.shortened_cherry').should == {:species => 'cherry', :average_diameter => 10}
      build_attributes(:big_cherry).should == {}
    end

    it "should use attributes when building" do
      build 'attributes.cherry'
      @attributes_cherry.species.should == 'cherry'
    end

    it "should automatically merge options to attributes" do
      build 'attributes.cherry' => {:species => 'a cherry'}
      @attributes_cherry.species.should == 'a cherry'
    end

    it "should reverse merge attributes from namespaces" do
      build 'attributes.cherry'
      @attributes_cherry.average_diameter.should == 10
    end

    it "should return build attributes for dependencies" do
      attrs = build_attributes('attributes.dependent_cherry')
      @the_pine.should_not be_nil
      attrs[:tree].should == @the_pine
    end
  end

  it "should not fail with circular reference" do
    build :circular_reference
  end

  it "should allow inferring blueprint name" do
    build(:infered).name.should == 'infered'
  end

  it "should allow building with :new strategy" do
    build_with(:new, :oak)
    @oak.should be_instance_of(Tree)
    @oak.should be_new_record
    @oak.name.should == 'Oak'
    @oak.size.should == 'large'
  end
end
