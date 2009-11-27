module Blueprints
  module DatabaseBackends
    class None
      def start_transaction
      end

      def revert_transaction
      end

      def delete_tables(delete_policy, *args)
      end
    end
  end
end
