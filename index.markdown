---
layout: application
title: Home
---

In spec/spec_helper.rb or test/test_helper.rb:

{% highlight ruby %}
Blueprints.enable
{% endhighlight %}

In spec/blueprint.rb or test/blueprint.rb:

{% highlight ruby %}
blueprint :apple do
  Fruit.create!(:species => 'apple')
end
{% endhighlight %}

In test case:

{% highlight ruby %}
it "should have species 'apple'" do
  build :apple
  @apple.species.should == 'apple'
end
{% endhighlight %}
