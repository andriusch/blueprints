module Blueprints
  module DatabaseBackends
    # Database backend when no orm is actually used. Can be adapted to work with any kind of data.
    class None
      # Dummy method
      def start_transaction
      end

      # Dummy method
      def rollback_transaction
      end

      # Dummy method
      def delete_tables(delete_policy, *args)
      end
    end
  end
end
