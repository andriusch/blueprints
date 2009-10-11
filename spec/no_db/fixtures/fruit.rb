class Fruit
  attr_accessor :species, :size

  def initialize(species, size = 5)
    @species = species
    @size = size
  end
end
