---
layout: application
title: Extending blueprints
---

You can also extend existing blueprints by creating another blueprint that builds blueprint with some options.

{% highlight ruby %}
# In blueprint.rb
Fruit.blueprint :apple, :species => 'apple', :color => 'yellow'

Fruit.blueprint(:red_apple).extends(:apple, :color => 'red')

blueprint :red_apple do
  build :apple, :color => 'red'
end

# In spec
it "should be red apple" do
  build :red_apple
  @red_apple.color.should == 'red'
  @apple.should eql(@red_apple)
end
{% endhighlight %}
</pre>

Note that you won't be able to build :apple, once :red_apple has been built.
