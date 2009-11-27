module Blueprints
  module DatabaseBackends
    class ActiveRecord
      DELETE_POLICIES = {:delete => "DELETE FROM %s", :truncate => "TRUNCATE %s"}

      def initialize
        ::ActiveRecord::Base.extend(ActiveRecordExtensions)
      end

      def start_transaction
        ::ActiveRecord::Base.connection.increment_open_transactions
        ::ActiveRecord::Base.connection.transaction_joinable = false
        ::ActiveRecord::Base.connection.begin_db_transaction
      end

      def rollback_transaction
        ::ActiveRecord::Base.connection.rollback_db_transaction
        ::ActiveRecord::Base.connection.decrement_open_transactions
      end

      def delete_tables(delete_policy, *args)
        delete_policy ||= :delete
        raise ArgumentError, "Unknown delete policy #{delete_policy}" unless DELETE_POLICIES.keys.include?(delete_policy)
        args = tables if args.blank?
        args.each { |t| ::ActiveRecord::Base.connection.delete(DELETE_POLICIES[delete_policy] % t) }
      end

      def tables
        ::ActiveRecord::Base.connection.tables - skip_tables
      end

      def skip_tables
        %w( schema_info schema_migrations )
      end

      module ActiveRecordExtensions
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
