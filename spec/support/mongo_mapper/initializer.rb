class Fruit
  include MongoMapper::Document

  key :species, String
  key :average_diameter, Integer

  belongs_to :tree
end

class Tree
  include MongoMapper::Document

  key :size

  attr_protected :size
  many :fruits
end

MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'blueprints_test'
