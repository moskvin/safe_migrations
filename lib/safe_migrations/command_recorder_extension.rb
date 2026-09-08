# frozen_string_literal: true

module SafeMigrations
  # Records safe schema operations and supplies their inverses.
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
      safe_add_check_constraint
      safe_remove_check_constraint
      safe_change_column_default
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
      safe_rename_column: :safe_rename_column,
      safe_add_reference: :safe_remove_reference,
      safe_add_check_constraint: :safe_remove_check_constraint,
      safe_change_column_default: :safe_change_column_default
    }.freeze

    def self.apply
      recorder = ActiveRecord::Migration::CommandRecorder
      register_commands(recorder)
      register_inverses(recorder)
      recorder.prepend(SpecialInversions)
    end

    def self.register_commands(recorder)
      SAFE_METHODS.each do |method|
        recorder.define_method(method) do |*args, &block|
          record(method, args, &block)
        end
        recorder.send(:ruby2_keywords, method)
      end
    end

    def self.register_inverses(recorder)
      SAFE_REVERSIBLE_MAP.each do |cmd, inv|
        recorder.define_method(:"invert_#{cmd}") do |args, &block|
          [inv, args, block]
        end
      end
    end

    # Operations whose inverses require transformed arguments.
    module SpecialInversions
      # Special case for safe_rename_column (swap column names)
      def invert_safe_rename_column(args)
        table, old_col, new_col = args
        [:safe_rename_column, [table, new_col, old_col]]
      end

      # Special case for safe_change_column_null (needs invert value)
      def invert_safe_change_column_null(args)
        table, column, value = args
        [:safe_change_column_null, [table, column, !value]]
      end

      def invert_safe_change_column_default(args)
        table, column, extra = args
        reverted_extra = { to: extra[:from], from: extra[:to] }
        [:safe_change_column_default, [table, column, reverted_extra]]
      end
    end
  end
end
