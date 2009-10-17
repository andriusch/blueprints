blueprint :apple do
  Fruit.create! :species => 'apple'
end

blueprint :many_apples => [:apple, :apple, :apple]

blueprint :bananas_and_apples => :apple do
  @banana = Fruit.create! :species => 'banana'
end

blueprint :orange do
  Fruit.create! :species => 'orange'
end

blueprint :fruit => [:apple, :orange] do
  [@orange, @apple]
end

blueprint :bananas_and_apples_and_oranges => [:bananas_and_apples, :orange] do
  @fruit = [@orange, @apple, @banana]
end

blueprint :cherry do
  Fruit.create! :species => 'cherry', :average_diameter => 3
end

blueprint :big_cherry => :cherry do
  Fruit.create! :species => @cherry.species, :average_diameter => 7
end

blueprint :cherry_basket => [:big_cherry, :cherry] do
  [@cherry, @big_cherry]
end

blueprint :parent_not_existing => :not_existing

Tree.blueprint :oak, :name => 'Oak', :size => 'large'

blueprint :pine do
  @the_pine = Tree.blueprint :name => 'Pine', :size => 'medium'
end

Fruit.blueprint(:acorn, :species => 'Acorn', :tree => :@oak).depends_on(:oak)

namespace :pitted do
  Fruit.blueprint :peach, :species => 'pitted peach'
end