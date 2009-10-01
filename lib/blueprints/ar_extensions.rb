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
          options.each do |attr, value|
            value = Blueprints::Plan.context.instance_variable_get(value) if value.is_a? Symbol and value.to_s =~ /^@.+$/
            object.send("#{attr}=", value)
          end
          object.save!
        end
      end
    end
  end
end