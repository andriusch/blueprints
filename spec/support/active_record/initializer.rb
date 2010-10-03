class Fruit < ActiveRecord::Base
  belongs_to :tree
end

class Tree < ActiveRecord::Base
  attr_protected :size
  has_many :fruits
end

db_config = YAML::load(Root.join("spec/support/active_record/database.yml").read)
ActiveRecord::Base.establish_connection(db_config)
ActiveRecord::Base.logger = @logger

@rspec1 = @version.to_s[0, 1] == '2'
@transactions = true
