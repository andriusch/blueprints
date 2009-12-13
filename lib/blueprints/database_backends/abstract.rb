module Blueprints
  module DatabaseBackends
    class Abstract
      # Method to start transaction. Needs to be implemented in child class.
      def start_transaction
        raise NotImplementedError
      end

      # Method to revert transaction. Needs to be implemented in child class.
      def revert_transaction
        raise NotImplementedError
      end

      # Method to clear tables. Should accept delete policy and list of tables to delete. If list of tables is empty, should
      # delete all tables. Needs to be implemented in child class.
      def delete_tables(delete_policy, *args)
        raise NotImplementedError
      end
    end
  end
end
