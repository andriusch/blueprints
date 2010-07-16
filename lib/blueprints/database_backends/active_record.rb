module Blueprints
  # Extensions for active record class
  module ActiveRecordExtensions
    module ClassMethods
      # Two forms of this method can be used. First one is typically used inside blueprint block. Essentially it does
      # same as <tt>create!</tt>, except it does bypass attr_protected and attr_accessible. It accepts only a hash or attributes,
      # same as <tt>create!</tt> does.
      #   blueprint :post => :user do
      #     @user.posts.blueprint(:title => 'first post', :text => 'My first post')
      #   end
      # The second form is used when you want to define new blueprint. It takes first argument as name of blueprint
      # and second one as hash of attributes. As you cannot use instance variables outside of blueprint block, you need
      # to prefix them with colon. So the example above could be rewritten like this:
      #   Post.blueprint(:post, :title => 'first post', :text => 'My first post', :user => d(:user))
      # or like this:
      #   Post.blueprint(:post, :title => 'first post', :text => 'My first post', :user => :@user).depends_on(:user)
      # or like this:
      #   Post.blueprint({:post => :user}, :title => 'first post', :text => 'My first post', :user => :@user)
      def blueprint(name_or_attrs, attrs = {})
        if Blueprints::FileContext.evaluating
          klass = self
          blueprint = Blueprints::Blueprint.new(name_or_attrs) { klass.blueprint attributes }
          blueprint.attributes(attrs)
          blueprint
        else
          if name_or_attrs.is_a?(Array)
            name_or_attrs.collect { |attrs| blueprint(attrs) }
          else
            object = new
            object.blueprint(name_or_attrs)
            object
          end
        end
      end
    end

    module InstanceMethods
      # Updates attributes of object and calls save!. Bypasses attr_protected and attr_accessible.
      def blueprint(attributes)
        send(:attributes=, Blueprints::Blueprint.normalize_attributes(attributes.dup), false)
        save!
      end
    end
  end
end

::ActiveRecord::Base.send(:include, Blueprints::ActiveRecordExtensions::InstanceMethods)
::ActiveRecord::Base.extend(Blueprints::ActiveRecordExtensions::ClassMethods)
