class Fruit
  include Mongoid::Document

  field :species
  field :size, :type => Integer

  attr_protected :size
end
