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
blueprint(:huge_oak).extends(:oak, :size => 'huge')

blueprint :pine do
  @the_pine = Tree.blueprint :name => 'Pine', :size => 'medium'
end

Fruit.blueprint(:acorn, :species => 'Acorn', :tree => d(:oak))
blueprint :small_acorn do
  build :acorn => {:average_diameter => 1}
end
blueprint(:huge_acorn => :huge_oak).extends(:acorn, :average_diameter => 100)

namespace :pitted => :pine do
  Tree.blueprint :peach_tree, :name => 'pitted peach tree'
  Fruit.blueprint(:peach, :species => 'pitted peach', :tree => :@peach_tree).depends_on(:peach_tree)
  Fruit.blueprint(:acorn, :species => 'pitted acorn', :tree => :@oak).depends_on(:oak)

  namespace :red => :orange do
    Fruit.blueprint(:apple, :species => 'pitted red apple')
  end
end

blueprint :apple_with_params do
  Fruit.create! options.reverse_merge(:species => 'apple')
end
