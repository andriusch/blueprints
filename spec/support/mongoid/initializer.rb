class Fruit
  include Mongoid::Document

  field :species
  field :average_diameter, :type => Integer

  referenced_in :tree, :inverse_of => :fruits
end

class Tree
  include Mongoid::Document

  field :size

  attr_protected :size
  references_many :fruits
end

Mongoid.configure do |config|
  config.logger = @logger
  config.from_hash YAML.load_file(Root.join('spec/support/mongoid/database.yml'))
end

