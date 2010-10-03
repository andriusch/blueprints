blueprint :cherry do
  Fruit.blueprint(:species => 'cherry')
end

blueprint :big_cherry do
  Fruit.blueprint(:species => 'cherry', :size => 10)
end

Fruit.blueprint :apple, :species => 'apple', :size => 3
