module Blueprints
  module DatabaseBackends
    class ActiveRecord
      DELETE_POLICIES = {:delete => "DELETE FROM %s", :truncate => "TRUNCATE %s"}

      # Extends active record with blueprint method
      def initialize
        ::ActiveRecord::Base.extend(ActiveRecordExtensions)
      end

      # Starts new transaction and marks it as unjoinable so that test case could use transactions too.
      def start_transaction
        ::ActiveRecord::Base.connection.increment_open_transactions
        ::ActiveRecord::Base.connection.transaction_joinable = false
        ::ActiveRecord::Base.connection.begin_db_transaction
      end

      # Rollbacks transaction
      def rollback_transaction
        ::ActiveRecord::Base.connection.rollback_db_transaction
        ::ActiveRecord::Base.connection.decrement_open_transactions
      end

      # Clears all tables using delete policy specified. Also accepts list of tables to delete.
      def delete_tables(delete_policy, *args)
        delete_policy ||= :delete
        raise ArgumentError, "Unknown delete policy #{delete_policy}" unless DELETE_POLICIES.keys.include?(delete_policy)
        args = tables if args.blank?
        args.each { |t| ::ActiveRecord::Base.connection.delete(DELETE_POLICIES[delete_policy] % t) }
      end

      # Returns all tables without skipped ones.
      def tables
        ::ActiveRecord::Base.connection.tables - skip_tables
      end

      # Returns tables that should never be cleared (those that contain migrations information).
      def skip_tables
        %w( schema_info schema_migrations )
      end

      # Extensions for active record class
      module ActiveRecordExtensions
        # Two forms of this method can be used. First one is typically used inside blueprint block. Essentially it does
        # same as <tt>create!</tt>, except it does bypass attr_protected and attr_accessible. It accepts only a hash or attributes,
        # same as <tt>create!</tt> does.
        #   blueprint :post => :user do
        #     @user.posts.blueprint(:title => 'first post', :text => 'My first post')
        #   end
        # The second form is used when you want to define new blueprint. It takes first argument as name of blueprint
        # and second one as hash of attributes. As you cannot use instance variables outside of blueprint block, you need
        # to prefix them with colon. So the example above could be rewritten like this:
        #   Post.blueprint(:post, :title => 'first post', :text => 'My first post', :user => :@user).depends_on(:user)
        # or like this:
        #   Post.blueprint({:post => :user}, :title => 'first post', :text => 'My first post', :user => :@user)
        def blueprint(*args)
          options = args.extract_options!
          if args.present?
            klass = self
            Blueprints::Plan.new(*args) do
              klass.blueprint options
            end
          else
            returning(self.new) do |object|
              options.each do |attr, value|
                value = Blueprints::Namespace.root.context.instance_variable_get(value) if value.is_a? Symbol and value.to_s =~ /^@.+$/
                object.send("#{attr}=", value)
              end
              object.save!
            end
          end
        end
      end

    end
  end
end
