blueprint :cherry do
  Fruit.new('cherry')
end

blueprint :big_cherry do
  Fruit.new('cherry', 10)
end

Fruit.blueprint :apple, :species => 'apple', :size => 3
