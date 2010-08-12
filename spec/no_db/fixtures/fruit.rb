class Fruit
  attr_accessor :species, :size

  def initialize(species, size = 5)
    @species = species
    @size = size
  end

  private
  
  def self.blueprint_object(attrs)
    new(attrs[:species], attrs[:size])
  end
end
