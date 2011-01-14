---
layout: application
title: Namespaces
---

Blueprints provides you with ability to group blueprints using namespaces. So for example if you have two blueprints:

{% highlight ruby %}
blueprint :red_apple do
  Fruit.create!(:species => 'apple')
end
blueprint :red_cherry do
  Fruit.create!(:species => 'cherry')
end
{% endhighlight %}

You could put them into namespace like this:

{% highlight ruby %}
namespace :red do
  blueprint :apple do
    Fruit.create!(:species => 'apple')
  end
  blueprint :cherry do
    Fruit.create!(:species => 'cherry')
  end
end
{% endhighlight %}

And then build in test case like this:

{% highlight ruby %}
build 'red.apple'
@red_apple.should_not be_nil
{% endhighlight %}

You could take even build whole namespace at once like this:

{% highlight ruby %}
build 'red'
@red.should == [@red_apple, @red_cherry]
{% endhighlight %}
This gives you additional bonus @red instance variable which contains results of all children blueprints blocks, so in
this case it would contain @red_apple and @red_cherry.

## Attributes and dependencies

Blueprints also inherit all attributes and dependencies of their namespaces.

{% highlight ruby %}
# In blueprints file
attributes(:color => 'red').namespace :red do
  Fruit.blueprint :apple, :name => 'apple'
end

# In test case
build 'red.apple'
@red_apple.color.should == 'red'
{% endhighlight %}
