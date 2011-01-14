---
layout: application
title: Inferring names
---

Blueprints can try to guess the name of the blueprints you're defining if you define attributes for that blueprint.

{% highlight ruby %}
# Inferred name :apple
Fruit.blueprint :name => 'apple'

# Inferred name :orange
attributes(:name => 'orange', :size => 'big').blueprint do
  Fruit.blueprint attributes
end
{% endhighlight %}

By default blueprints use value of :name attributes, however this can be configured with `Blueprints.config.default_attributes`
