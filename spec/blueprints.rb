plan :apple do
  Fruit.create! :species => 'apple'
end

plan :many_apples => [:apple, :apple, :apple]

plan :bananas_and_apples => :apple do
  @banana = Fruit.create! :species => 'banana'
end

plan :orange do
  Fruit.create! :species => 'orange'
end

plan :fruit => [:apple, :orange] do
  [@orange, @apple]
end

plan :bananas_and_apples_and_oranges => [:bananas_and_apples, :orange] do
  @fruit = [@orange, @apple, @banana]
end

plan :cherry do
  Fruit.create! :species => 'cherry', :average_diameter => 3
end

plan :big_cherry => :cherry do
  Fruit.create! :species => @cherry.species, :average_diameter => 7
end

plan :cherry_basket => [:big_cherry, :cherry] do
  [@cherry, @big_cherry]
end

plan :parent_not_existing => :not_existing