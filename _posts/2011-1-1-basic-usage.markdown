---
layout: application
title: Basic usage
---

## Setup

The easiest way to install this gem is simply adding this line to your Gemfile:

{% highlight ruby %}
gem 'blueprints'
{% endhighlight %}


If you're not using bundler, then you can install it through command line

{% highlight ruby %}
sudo gem install blueprints
{% endhighlight %}

Blueprints is activated by calling Blueprints.enable at the bottom of your spec_helper/test_helper.

{% highlight ruby %}
# spec/spec_helper.rb
Blueprints.enable
{% endhighlight %}

## Blueprints file

Blueprints file is the file that contains all definitions of blueprints. This can either be single file or whole folder
if you have many blueprints.

By default blueprints are searched in these files in this particular order in application root (which is either Rails.root if it's defined or current folder by default):

{% include file_patterns.markdown %}

You can set root option to override application root and filename option to pass custom filename pattern. For more information see [configuration](/blueprints/configuration)

### Definitions

Definitions of blueprints look like this:

{% highlight ruby %}
blueprint :apple do
  Fruit.blueprint :species => 'apple'
end

blueprint :orange do
  Fruit.create! :species => 'orange'
end

blueprint :fruitbowl => [:apple, :orange] do
  @fruits = [@apple,@orange]
  FruitBowl.blueprint :fruits => @fruits
end

Kitchen.blueprint :kitchen, :fruitbowl => d(:fruitbowl)
{% endhighlight %}

Note that in :fruitbowl and :kitchen blueprints we define depenendencies on other blueprints, meaning that once we build
:fruitbowl, then :apple and :orange will also be built and when we build :kitchen then :fruitbowl with all it's
dependencies will be built.

### Usage

You can use your defined blueprints in specs(tests) like this:

{% highlight ruby %}
describe Fruit, "apple" do
  before do
    build :apple
  end

  it "should be an apple" do
    @apple.species.should == 'apple'
  end
end

describe FruitBowl, "with and apple and an orange" do
  before do
    build :fruitbowl
  end

  it "should have 2 fruits" do
    @fruits.should == [@apple, @orange]
    @fruitbowl.should have(2).fruits
  end
end
{% endhighlight %}

Result of 'blueprint' block is assigned to an instance variable with the same name. You can also assign your own instance variables
inside 'blueprint' block and they will be accessible in tests that build this blueprint.

Instead of SomeModel.create! you can also use SomeModel.blueprint, which does the same thing but also bypasses attr_protected
and attr_accessible restrictions (which is what you usually want in tests).

All blueprints are run only once, no matter how many times they were called, meaning that you don't need to worry about
duplicating data.

### Shorthands

There's a shorthand for these type of scenarios:

{% highlight ruby %}
blueprint :something do
  @something = SomeModel.blueprint :field => 'value'
end
{% endhighlight %}

You can just type:

{% highlight ruby %}
SomeModel.blueprint :something, :field => 'value'
{% endhighlight %}

If you need to make associations then:

{% highlight ruby %}
SomeModel.blueprint(:something, :association => d(:some_blueprint))
{% endhighlight %}

...or if the name of blueprint and the name of instance variable are not the same:

{% highlight ruby %}
SomeModel.blueprint(:something, :association => d(:some_blueprint, :some_instance_variable))
{% endhighlight %}

...and when you need to pass options to associated blueprint:

{% highlight ruby %}
SomeModel.blueprint(:something, :association => d(:some_blueprint, :option => 'value'))
{% endhighlight %}

You can learn more about blueprint method in http://wiki.github.com/sinsiliux/blueprints/method-blueprint

### Advanced Usage

Its just ruby, right? So go nuts:

{% highlight ruby %}
1.upto(9) do |i|
  blueprint("user_#{i}") do
    User.blueprint :name => "user#{i}"
  end
end
{% endhighlight %}

You can also read more about advanced usages in http://wiki.github.com/sinsiliux/blueprints/advanced-usages
