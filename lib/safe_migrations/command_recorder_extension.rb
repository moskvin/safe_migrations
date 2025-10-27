# frozen_string_literal: true

module SafeMigrations
  module CommandRecorderExtension
    SAFE_METHODS = %i[
      safe_create_table
      safe_drop_table
      safe_add_column
      safe_remove_column
      safe_rename_column
      safe_add_index
      safe_remove_index
      safe_add_foreign_key
      safe_remove_foreign_key
      safe_add_column_and_index
      safe_remove_column_and_index
      safe_change_column
      safe_change_column_null
      safe_add_reference
      safe_remove_reference
    ].freeze

    SAFE_REVERSIBLE_MAP = {
      safe_create_table: :safe_drop_table,
      safe_add_column: :safe_remove_column,
      safe_remove_column: :safe_add_column,
      safe_add_index: :safe_remove_index,
      safe_remove_index: :safe_add_index,
      safe_add_foreign_key: :safe_remove_foreign_key,
      safe_remove_foreign_key: :safe_add_foreign_key,
      safe_add_column_and_index: :safe_remove_column_and_index,
      safe_remove_column_and_index: :safe_add_column_and_index,
      safe_change_column_null: :safe_change_column_null,
      safe_add_reference: :safe_remove_reference
    }.freeze

    def self.apply
      ActiveRecord::Migration::CommandRecorder.class_eval do
        SAFE_METHODS.each do |method|
          define_method(:"#{method}") do |*args, &block|
            record(:"#{method}", args, &block)
          end
          ruby2_keywords(method)
        end

        SAFE_REVERSIBLE_MAP.each do |cmd, inv|
          define_method(:"invert_#{cmd}") do |args, &block|
            [inv, args, block]
          end
        end

        # Special case for safe_rename_column (swap column names)
        def invert_safe_rename_column(args)
          table, old_col, new_col = args
          [:safe_rename_column, [table, new_col, old_col]]
        end

        # Special case for safe_change_column (needs type tracking)
        def invert_safe_change_column(args)
          table, column, type, options = args
          # If column existed, invert to original type (not tracked, so warn)
          # If column was added, invert to remove
          [:safe_remove_column, [table, column, type, options]]
        end
      end
    end
  end
end
