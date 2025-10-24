module SafeMigrations
  module MigrationHelper
    def self.included(base)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def safe_add_column(table, column, type, **options)
        return unless table_exists?(table)
        return if column_exists?(table, column)

        add_column(table, column, type, **options)
      end

      def safe_remove_column(table, column, type = nil, **options)
        table_exists?(table) && column_exists?(table, column) && remove_column(table, column, type, **options)
      end

      def safe_rename_column(table_name, column_name, new_column_name)
        column_exists?(table_name, column_name) && !column_exists?(table_name, new_column_name) && rename_column(table_name, column_name, new_column_name)
      end

      def safe_add_index(table, column, **options)
        return unless table_exists?(table)
        return if index_exists?(table, column, **options)

        add_index(table, column, **options)
      end

      def safe_remove_index(table, column_name = nil, **options)
        index_exists?(table, column_name, **options) && remove_index(table, column_name, **options)
      end

      def safe_add_column_and_index(table, column, type, column_options = {}, index_options = {})
        safe_add_column(table, column, type, **column_options)
        safe_add_index(table, column, **index_options)
      end

      def safe_remove_column_and_index(table, column, column_options = {}, index_options = {})
        safe_remove_index(table, column, **index_options)
        safe_remove_column(table, column, **column_options)
      end

      def safe_change_column(table, column, type, **options)
        column_exists?(table, column) ? change_column(table, column, type, **options) : add_column(table, column, type, **options)
      end

      def safe_change_column_null(table, column, null, default = nil)
        column_exists?(table, column) && change_column_null(table, column, null, default)
      end

      def safe_create_table(table, **options, &block)
        create_table(table, **options, &block) unless table_exists?(table)
      end

      def safe_drop_table(table, **)
        drop_table(table, if_exists: true, **) if table_exists?(table)
      end

      def safe_add_foreign_key(from_table, to_table, **options)
        return unless table_exists?(from_table) && table_exists?(to_table)
        return if foreign_key_exists?(from_table, to_table, **options)

        add_foreign_key(from_table, to_table, **options)
      end

      def safe_remove_foreign_key(from_table, to_table, **options)
        table_exists?(from_table) && table_exists?(to_table) && foreign_key_exists?(from_table, to_table, **options) && remove_foreign_key(from_table, to_table, **options)
      end
    end
  end
end
