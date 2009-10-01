require 'active_record'

module ActiveRecord
  class Base
    def self.blueprint(*args)
      options = args.extract_options!
      if args.present?
        klass = self
        Blueprints::Plan.new(*args) do
          klass.blueprint options
        end
      else
        returning(self.new) do |object|
          options.each {|attr, value| object.send("#{attr}=", value)}
          object.save!
        end
      end
    end
  end
end