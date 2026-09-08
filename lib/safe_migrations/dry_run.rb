# frozen_string_literal: true

module SafeMigrations
  module DryRun
    def self.included(base)
      base.class_attribute(:safe_migrations_dry_runnable, instance_accessor: false, default: false)
      base.extend(ClassMethods)
      base.prepend(Execution)
    end

    module ClassMethods
      def dry_runnable
        self.safe_migrations_dry_runnable = true
      end
    end

    module Execution
      def exec_migration(conn, direction)
        if direction == :up && self.class.safe_migrations_dry_runnable
          perform_dry_run(conn) { super }
        else
          super
        end
      end
    end

    def dry_run?
      !!ActiveModel::Type::Boolean.new.cast(ENV['DRY_RUN'])
    end

    def dry_runnable(&block)
      perform_dry_run(connection, &block)
    end

    private

    def perform_dry_run(conn)
      return yield unless dry_run?

      if self.class.disable_ddl_transaction || !conn.supports_ddl_transactions?
        raise SafeMigrations::Error, 'DRY_RUN requires a migration with DDL transactions enabled and an adapter that supports them'
      end
      unless conn.transaction_open?
        raise SafeMigrations::Error, 'DRY_RUN requires an active migration transaction; run through Rails migration tasks'
      end

      say 'DRY_RUN: executing inside the migration transaction'
      yield
      say 'DRY_RUN: rolling back; migration will remain pending'
      # This must reach the migrator's transaction, before it records the version.
      raise ActiveRecord::Rollback
    end
  end
end
