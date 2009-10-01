class Tree < ActiveRecord::Base
  attr_protected :size
  has_many :fruits
end