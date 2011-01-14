module ActiveRecord
  module ConnectionAdapters
    class Mysql2Adapter < AbstractAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
      end
    end
  end
end
