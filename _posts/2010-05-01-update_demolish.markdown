---
layout: application
title: Updating and destroying
---

## Demolishing built blueprints

It is possible to demolish blueprint that has already been built (mostly used for prebuilt blueprints). Similarly to
build method demolish takes array of arguments, but instead of building those blueprints it demolishes them. By default
this calls `destroy` method on return value of blueprint block, but can be customized.

{% highlight ruby %}
# Destroy :apple and :peach
demolish :apple, :peach

# in blueprint.rb file
blueprint :apple do
  Fruit.blueprint :species => 'apple'
end.demolish do
  @apple.delete
end

# This now calls @apple.delete instead of default @apple.destroy
demolish :apple
{% endhighlight %}


## Updating blueprints

Since version 0.8.0 building a blueprint with options when it was already built allows to update it. By default this
simply calls `blueprint` method with passed options on return value of blueprint block, but can be customized.

{% highlight ruby %}
# Build :apple and later update it with 'autumn apple' species
build :apple
...
build :apple => {:species => 'autumn apple'}

# in blueprint.rb file
blueprint :apple do
  Fruit.blueprint :species => 'apple'
end.update do
  @apple.attributes = options
end

# This now only sets attributes for @apple but doesn't save it
build :apple
...
build :apple => {:species => 'autumn apple'}
{% endhighlight %}
