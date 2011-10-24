db_config = YAML::load_file(File.expand_path("../database.yml", __FILE__))
ActiveRecord::Base.establish_connection(db_config)
ActiveRecord::Base.logger = @logger

class Fruit < ActiveRecord::Base
  belongs_to :tree
end

class Tree < ActiveRecord::Base
  attr_protected :size
  has_many :fruits, :after_add => :fruit_after_add
  belongs_to :main_fruit, :class_name => 'Fruit'

  def fruit_after_add(_)
  end
end

@rspec1 = @version.to_s[0, 1] == '2'
@transactions = true
