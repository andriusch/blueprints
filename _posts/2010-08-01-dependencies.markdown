---
layout: application
title: Dependencies and build!
---

Any blueprint can have dependencies. Dependencies mean that that building one blueprint will also build another. Note
that each blueprint can only be built once.

## Defining dependencies

There are several ways to define dependencies:

### Hash

First way is similar to what rake uses - passing dependencies as values of hash key (which then becomes name of blueprint).

{% highlight ruby %}
# define blueprint :fruits which depends on :apple and :orange
blueprint :fruits => [:apple, :orange]

# define blueprint :apple_tree which depends on :apple
blueprint :apple_tree => :apple do
  # Note that we have @apple defined from :apple blueprint, since we defined it as a dependency
  Tree.blueprint :fruit => @apple
end
{% endhighlight %}

### Depends on

Another way is using `depends_on` method which. This can be used in three different forms: prefix, postfix and block.

{% highlight ruby %}
blueprint(:fruits).depends_on(:apple, :orange)

depends_on(:apple, :orange).blueprint(:fruits)

depends_on(:apple, :orange) do
  # Any blueprints we define inside this block will depends on :apple and :orange
  blueprint :fruits
  blueprint :round_fruits
end
{% endhighlight %}

### Method `d`

Method `d` is a bit special case in a way that not only it defined dependency but also assigns it to some attribute.

{% highlight ruby %}
# Define blueprint named :apple_tree which when built will build :apple and assign
# :fruit with @apple
Tree.blueprint :apple_tree, :fruit => d(:apple)

# Define blueprint named :apple_tree which when built will build :apple with options
# {:color => 'red'} and assign :fruit with @apple_fruit
Tree.blueprint :apple_tree, :fruit => d(:apple, :apple_fruit, :color => 'red')

# Define blueprint name :apple_tree which when built will build :apple and assign
# :fruit_name with @apple.name
Tree.blueprint :apple_tree, :fruit => d(:apple).name
{% endhighlight %}

## Building multiple times

Sometimes you need same blueprint build multiple times (eg. testing pagination). For that you can use `build` method.
Note that any dependencies of those blueprints will only be built once.

{% highlight ruby %}
it "should paginate correctly" do
  users = (0..5).collect { build! :user }
  User.paginate(:per_page => 5, :page => 1).should == users[0..4]
end
{% endhighlight %}
