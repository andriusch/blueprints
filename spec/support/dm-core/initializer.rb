class Fruit
  include DataMapper::Resource

  property :id, Serial
  property :species, String
  property :average_diameter, Integer

  belongs_to :tree, :required => false, :default => nil
end

class Tree
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :size, String, :writer => :private

  has n, :fruits
end

DataMapper::Model.raise_on_save_failure = true

require 'dm-transactions'
require 'dm-migrations'

DataMapper::Logger.new(@logger_file, :debug)
DataMapper.setup(:default, 'mysql://localhost/blueprints_test')
DataMapper.finalize
DataMapper.auto_migrate!

@transactions = true
