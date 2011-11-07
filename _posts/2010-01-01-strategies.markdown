---
layout: application
title: Strategies
---

Each blueprint can define multiple strategies on how it can be built. For example this blueprint

{% highlight ruby %}
blueprint :sample do
  12
end.blueprint :twice do
  24
end
{% endhighlight %}

will have 2 strategies: `:default` and `:twice`. Depending on what strategy you choose when building blueprint you will
get different result. You can choose strategy by using `build_with :strategy, :blueprint`.

## Short blueprint form

The short blueprint form (using Class.blueprint :name, :attribute => 'value') automatically defines 4 strategies:
`:default`, `:update`, `:new`, `:demolish`.

{% highlight ruby %}
# In blueprints file
User.blueprint(:user, :username => 'admin', :password => 'secret')

# In test case
it "should define attributes" do
  build_with(:new, :user).should be_a_new(User)
  @user.username.should == 'admin'
end
{% endhighlight %}

# DSL and strategies

All blueprints DSL methods actually just build some strategy. Here's a list of methods with what strategies they use:

<table>
  <tr>
    <th>Method</th>
    <th>Strategy</th>
  </tr>
  <tr>
    <td>build</td>
    <td>:default first time, :update subsequent times</td>
  </tr>
  <tr>
    <td>build!</td>
    <td>:default</td>
  </tr>
  <tr>
    <td>demolish</td>
    <td>:demolish</td>
  </tr>
</table>
