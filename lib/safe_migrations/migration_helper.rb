# frozen_string_literal: true

module SafeMigrations
  # Adds idempotent schema operations to database adapters.
  module MigrationHelper
    def self.included(base)
      base.send(:include, InstanceMethods)
    end

    # Checks schema state before applying each operation.
    module InstanceMethods
      def safe_add_column(table, column, type, **)
        return unless table_exists?(table)
        return if column_exists?(table, column)

        add_column(table, column, type, **)
      end

      def safe_remove_column(table, column, type = nil, **)
        table_exists?(table) && column_exists?(table, column) && remove_column(table, column, type, **)
      end

      def safe_rename_column(table_name, column_name, new_column_name)
        column_exists?(table_name, column_name) &&
          !column_exists?(table_name, new_column_name) &&
          rename_column(table_name, column_name, new_column_name)
      end

      def safe_add_index(table, column, **)
        return unless table_exists?(table)
        return if index_exists?(table, column, **)

        add_index(table, column, **)
      end

      def safe_remove_index(table, column_name = nil, **)
        index_exists?(table, column_name, **) && remove_index(table, column_name, **)
      end

      def safe_add_column_and_index(table, column, type, column_options = {}, index_options = {})
        safe_add_column(table, column, type, **column_options)
        safe_add_index(table, column, **index_options)
      end

      def safe_remove_column_and_index(table, column, column_options = {}, index_options = {})
        safe_remove_index(table, column, **index_options)
        safe_remove_column(table, column, **column_options)
      end

      def safe_change_column(table, column, type, **)
        if column_exists?(table, column)
          change_column(table, column, type, **)
        else
          add_column(table, column, type, **)
        end
      end

      def safe_change_column_null(table, column, null, default = nil)
        column_exists?(table, column) && change_column_null(table, column, null, default)
      end

      def safe_create_table(table, **, &)
        create_table(table, **, &) unless table_exists?(table)
      end

      def safe_drop_table(table, **)
        drop_table(table, if_exists: true, **) if table_exists?(table)
      end

      def safe_add_foreign_key(from_table, to_table, **)
        return unless table_exists?(from_table) && table_exists?(to_table)
        return if foreign_key_exists?(from_table, to_table, **)

        add_foreign_key(from_table, to_table, **)
      end

      def safe_remove_foreign_key(from_table, to_table, **)
        table_exists?(from_table) && table_exists?(to_table) &&
          foreign_key_exists?(from_table, to_table, **) &&
          remove_foreign_key(from_table, to_table, **)
      end

      def safe_add_reference(table, ref_name, **)
        return unless table_exists?(table)

        column_exists?(table, "#{ref_name.to_s.singularize}_id") || add_reference(table, ref_name, **)
      end

      def safe_remove_reference(table, ref_name, **)
        table_exists?(table) && column_exists?(table, "#{ref_name.to_s.singularize}_id") &&
          remove_reference(table, ref_name, **)
      end

      def check_constraint_exists?(table_name, **options)
        if !options.key?(:name) && !options.key?(:expression)
          raise ArgumentError, 'At least one of :name or :expression must be supplied'
        end

        check_constraint_for(table_name, **options).present?
      end

      def safe_add_check_constraint(table, condition, name:, **)
        return unless table_exists?(table)

        check_constraint_exists?(table, name:) || add_check_constraint(table, condition, name:, **)
      end

      def safe_remove_check_constraint(table, condition, name:, **)
        table_exists?(table) && check_constraint_exists?(table, name:) &&
          remove_check_constraint(table, condition, name:, **)
      end

      def safe_change_column_default(table, column, default_or_changes)
        return unless table_exists?(table)

        column_exists?(table, column) && change_column_default(table, column, default_or_changes)
      end
    end
  end
end
