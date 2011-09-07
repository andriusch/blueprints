module Blueprints::Extensions
  # Here to support ActiveSupport 2.x. Will be removed once support for ActiveRecord 2.3 is terminated.
  module Extendable
    def self.included(mod)
      if defined?(ActiveSupport::Concern)
        mod.extend ActiveSupport::Concern
      else
        def mod.included(mod)
          mod.extend Blueprints::Extensions::Blueprintable::ClassMethods
        end
      end
    end
  end

# Include this module into your class if you need klass.blueprint and object.blueprint methods.
  module Blueprintable
    include Extendable

    module ClassMethods
      # @overload blueprint(attributes)
      #   Does same as +create!+ method except that it also bypasses attr_protected and attr_accessible. Typically used in blueprint block.
      #   @example Create post for user
      #     @user.posts.blueprint(:title => 'first post', :text => 'My first post')
      #   @param [Hash, Array<Hash>] attributes Attributes used to create objects.
      #   @return Created object(s).
      # @overload blueprint(name, attributes = {})
      #   Defines new blueprint that creates an object with attributes passed.
      #   @example Create blueprint named :post.
      #     Post.blueprint(:post, :title => 'first post', :text => 'My first post', :user => d(:user)).depends_on(:board)
      #   @param [String, Symbol, Hash] name Name of blueprint.
      #   @param [Hash] attributes Attributes hash.
      #   @return [Blueprints::Blueprint] Defined blueprint.
      def blueprint(*args)
        if Blueprints::Context.current
          attrs = args.extract_options!
          define_blueprint(args.first || Blueprints::Buildable.infer_name(attrs) || name.underscore, attrs)
        else
          objects = args.collect { |attrs| blueprint_object(attrs) }
          args.size == 1 ? objects.first : objects
        end
      end

      private

      def define_blueprint(name, attrs)
        klass = self
        Blueprints::Context.current.attributes(attrs).blueprint(name) do
          klass.blueprint attributes
        end.blueprint(:new) do
          klass.new.tap { |object| object.blueprint_without_save(attributes) }
        end
      end

      def blueprint_object(attrs)
        new.tap { |object| object.blueprint(attrs) }
      end
    end

    # Updates attributes of object by calling setter methods. Does same as +update_attributes!+ except it also bypasses attr_protected and attr_accessible.
    # @param [Hash] attributes Attributes that are used to update object.
    def blueprint(attributes)
      attributes.each do |attribute, value|
        blueprint_attribute attribute, value
      end
    end
    alias blueprint_without_save blueprint

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

    # Overrides object.blueprint to also call save
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

if defined?(ActiveRecord)
  ActiveRecord::Base.send(:include, Blueprints::Extensions::Saveable)
  # AssociationCollection for ActiveRecord 3.0, Collection::Association for ActiveRecord 3.1
  collection_class = defined?(ActiveRecord::Associations::CollectionAssociation) ? ActiveRecord::Associations::CollectionAssociation : ActiveRecord::Associations::AssociationCollection
  collection_class.class_eval do
    include Blueprints::Extensions::Blueprintable::ClassMethods

    def blueprint_object(attrs)
      create! do |object|
        object.blueprint_without_save(attrs)
      end
    end
  end
end
Mongoid::Document.send(:include, Blueprints::Extensions::DynamicSaveable) if defined?(Mongoid)
MongoMapper::Document.send(:append_inclusions, Blueprints::Extensions::DynamicSaveable) if defined?(MongoMapper)
DataMapper::Model.send(:append_inclusions, Blueprints::Extensions::SoftSaveable) if defined?(DataMapper)
