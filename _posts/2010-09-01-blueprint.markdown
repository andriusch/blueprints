---
layout: application
title: Method 'blueprint'
---

## Case 1

Defining new blueprint in **blueprints file**.

{% highlight ruby %}
blueprint :person do
  Person.create! :name => 'Namey'
end
{% endhighlight %}

You can also define blueprint with regexp name.

{% highlight ruby %}
# In blueprints file
blueprint /user_(\w+)/ do
  User.blueprint :name => options[:arg0]
end

# In spec
build :user_john
@john.name.should == 'john'
{% endhighlight %}

You can even take this one step further in ruby 1.9 with named groups.

{% highlight ruby %}
# In blueprints file
blueprint /user_(?<name>\w+)/ do
  User.blueprint options
end

# In spec
build :user_john
@john.name.should == 'john'
{% endhighlight %}

## Case 2

On active record **class** instead of create!, to create new object bypassing attr_protected and attr_accessible.

{% highlight ruby %}
blueprint :person do
  Person.blueprint :name => 'Namey', :protected_attribute => 1
end
{% endhighlight %}

## Case 3

On active record **object** instead of update_attributes!, to update object bypassing attr_protected and attr_accessible.

{% highlight ruby %}
blueprint :person do
  @person = Person.create! :name => 'Namey'
  @person.blueprint(:protected_attribute => 1)
end
{% endhighlight %}

## Case 4

In **blueprints file outside blueprint block**, as a convenience method to define new blueprint that creates one active record object.

{% highlight ruby %}
Person.blueprint :person, :name => 'Namey'
{% endhighlight %}
