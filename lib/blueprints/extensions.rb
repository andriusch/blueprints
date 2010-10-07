module Blueprints::Extensions
  module Extendable
    def self.included(mod)
      if defined?(ActiveSupport::Concern)
        mod.extend ActiveSupport::Concern
      else
        def mod.included(mod)
          mod.extend Blueprints::Blueprintable::ClassMethods
        end
      end
    end
  end

# Include this module into your class if you need klass.blueprint and object.blueprint methods.
  module Blueprintable
    include Extendable

    module ClassMethods
      # Two forms of this method can be used. First one is typically used inside blueprint block. Essentially it does
      # same as <tt>create!</tt>, except it does bypass attr_protected and attr_accessible. It accepts only a hash or attributes,
      # same as <tt>create!</tt> does.
      #   blueprint :post => [:user, :board] do
      #     @user.posts.blueprint(:title => 'first post', :text => 'My first post')
      #   end
      # The second form is used when you want to define new blueprint. It takes first argument as name of blueprint
      # and second one as hash of attributes. As you cannot use instance variables outside of blueprint block, you need
      # to prefix them with colon. So the example above could be rewritten like this:
      #   Post.blueprint(:post, :title => 'first post', :text => 'My first post', :user => d(:user)).depends_on(:board)
      def blueprint(name_or_attrs, attrs = {})
        if Blueprints::FileContext.current
          define_blueprint(name_or_attrs, attrs)
        else
          if name_or_attrs.is_a?(Array)
            name_or_attrs.collect { |attrs| blueprint(attrs) }
          else
            blueprint_object(name_or_attrs)
          end
        end
      end

      private

      def define_blueprint(name, attrs)
        klass = self
        blueprint = Blueprints::Blueprint.new(name, Blueprints::FileContext.current.namespaces.last, Blueprints::FileContext.current.file) { klass.blueprint attributes }
        blueprint.attributes(attrs)
        blueprint
      end

      def blueprint_object(attrs)
        new.tap { |object| object.blueprint(attrs) }
      end
    end

    # Updates attributes of object by calling setter methods.
    def blueprint(attributes)
      Blueprints::Blueprint.normalize_attributes(attributes).each do |attribute, value|
        blueprint_attribute attribute, value
      end
    end

    private

    def blueprint_attribute(attribute, value)
      send(:"#{attribute}=", value)
    end
  end

  # Include this instead of Blueprints::Extensions::Blueprintable if record needs to persist, includes Blueprints::Extensions::Blueprintable
  module Saveable
    include Extendable
    include Blueprintable

    # Overrides object.blueprint to also call save!
    def blueprint(attributes)
      super(attributes)
      save!
    end
  end

  # Include this instead of Blueprints::Extensions::Saveable if you want non bang save method (eg.using datamapper)
  module SoftSaveable
    include Extendable
    include Blueprintable

    # Overrides object.blueprint to also call save!
    def blueprint(attributes)
      super(attributes)
      save
    end
  end

  # Include this instead of Blueprints::Extensions::Saveable if you need support for dynamic attributes (eg. using mongodb)
  module DynamicSaveable
    include Extendable
    include Saveable

    private

    def blueprint_attribute(attribute, value)
      setter = :"#{attribute}="
      if respond_to?(setter)
        send(setter, value)
      else
        write_attribute(attribute, value)
      end
    end
  end
end

ActiveRecord::Base.send(:include, Blueprints::Extensions::Saveable) if defined?(ActiveRecord)
Mongoid::Document.send(:include, Blueprints::Extensions::DynamicSaveable) if defined?(Mongoid)
DataMapper::Model.send(:append_inclusions, Blueprints::Extensions::SoftSaveable) if defined?(DataMapper)
