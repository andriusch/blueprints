module Blueprints
  module DatabaseBackends
    class Abstract
      def start_transaction
        raise NotImplementedError
      end

      def revert_transaction
        raise NotImplementedError
      end

      def delete_tables(delete_policy, *args)
        raise NotImplementedError
      end
    end
  end
end
