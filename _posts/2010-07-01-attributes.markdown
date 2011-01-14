---
layout: application
title: Attributes and options
---

## Options

Each blueprint can be built using options hash.

{% highlight ruby %}
# In blueprints file:
blueprint :options do
  options
end

# In test case
it "should return options" do
  build :options => {:attribute => 'value'}
  @options.should == {:attribute => 'value'}
end
{% endhighlight %}

## Attributes

Each blueprint may have attributes defined. Attributes can be set using prefix, postfix and block form. Inside blueprint
block attributes can be accessed using `attributes` method.

{% highlight ruby %}
attributes(:name => 'apple').blueprint :apple do
  Fruit.blueprint attributes
end

blueprint :apple do
  Fruit.blueprint attributes
end.attributes(:name => 'apple')

attributes(:name => 'apple') do
  # Any blueprints inside will have their attributes merged with {:name => 'apple'}
  blueprint :apple do
    Fruit.blueprint attributes
  end

  attributes(:size => 'big').blueprint :big_apple do
    # attributes == {:name => 'apple', :size => 'big'}
    Fruit.blueprint attributes
  end
end
{% endhighlight %}

Attributes are automatically merged with options at build time, so given blueprints above, this test would pass:

{% highlight ruby %}
it "should merge options to attributes" do
  build :big_apple => {:size => 'small'}
  @big_apple.name.should == 'apple'
  # Note that passed options overwrite attributes
  @big_apple.size.should == 'small'
end
{% endhighlight %}

## Method `build_attributes`

You can also get attributes for any blueprint using `build_attributes` method. This may be usefull for example in
controller tests (testing create action).

{% highlight ruby %}
# In blueprints file
attributes(:username => 'admin', :password => 'secret').blueprint(:user) do
  User.blueprint attributes
end

# In test case
it "should create user" do
  expect {
    post :create, :user => build_attributes(:user)
  }.to change(User, :count).by(1)
  assigns[:user].username.should == 'admin'
  assigns[:user].password.should == 'secret'
end
{% endhighlight %}

## Short blueprint form

The short blueprint form (using Class.blueprint :name, :attribute => 'value') automatically defines attributes.

{% highlight ruby %}
# In blueprints file
User.blueprint(:user, :username => 'admin', :password => 'secret')

# In test case
it "should define attributes" do
  build_attributes(:user).should == {:username => 'admin', :password => 'secret'}
end
{% endhighlight %}
