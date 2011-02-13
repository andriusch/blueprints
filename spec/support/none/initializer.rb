class NoneOrm
  include Blueprints::Extensions::Blueprintable

  class << self
    def add (record)
      @all ||= []
      @all << record
    end

    def destroy(record)
      @all.delete record
    end

    def count
      all.size
    end

    def all(options = {})
      Array(@all).clone.tap do |result|
        result.reject! do |record|
          options[:conditions].any? { |key, value| record.send(key) != value }
        end if options[:conditions]
      end
    end

    def first(options = {})
      all(options).first
    end

    def last(options = {})
      all(options).last
    end
  end

  def initialize #(params)
#    params.each { |param, value| instance_variable_set("@#{param}", value) }
    self.class.add(self)
  end

  def reload
    self
  end

  def destroy
    self.class.destroy(self)
  end

  def new_record?
    true
  end
end

class Fruit < NoneOrm
  attr_accessor :species, :average_diameter, :tree
end

class Tree < NoneOrm
  attr_accessor :name, :size, :fruits
end

RSpec.configure do |config|
  config.before do
    [Fruit, Tree].each do |klass|
      klass.instance_variables.each { |iv| klass.send(:remove_instance_variable, iv) }
    end
  end
end
