---
layout: application
title: Most and least used
---

## Most used blueprints

Blueprints allow you to list most used blueprints so that you could know which blueprints are best candidates for
prebuilding. For example this code will print names of blueprints that have been used in more than half tests.

{% highlight ruby %}
RSpec.configure
  config.after :suite do
    most_used = Blueprints.most_used(:count => 10, :at_least => RSpec.world.example_count / 2)
    if most_used.present?
      puts "Blueprints used in more than half tests:"
      most_used.each { |name, uses| puts "* #{name} - #{uses}" }
    end
  end
end
{% endhighlight %}

## Unused blueprints

Blueprints also allow you to get a list of blueprints that have never been used so that you could remove them from your
blueprints file.

{% highlight ruby %}
RSpec.configure
  config.after :suite do
    unused = Blueprints.unused
    if unused.present?
      puts "Unused blueprints:"
      unused.each { |name| puts "* #{name}" }
    end
  end
end
{% endhighlight %}
