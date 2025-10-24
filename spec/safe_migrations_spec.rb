# frozen_string_literal: true

def run_migration(migration_class, direction: :up)
  migration = migration_class.new
  migration.migrate(direction)
end

# Helper to check if table/column/index exists
def table_exists?(table)
  ActiveRecord::Base.connection.table_exists?(table)
end

def column_exists?(table, column)
  ActiveRecord::Base.connection.column_exists?(table, column)
end

def index_exists?(table, column)
  ActiveRecord::Base.connection.index_exists?(table, column)
end

RSpec.describe SafeMigrations do
  let(:migration_class) do
    Class.new(ActiveRecord::Migration[7.2]) do
      def change
        safe_create_table(:users) do |t|
          t.string :name
          t.timestamps
        end
        safe_add_column(:users, :email, :string)
        safe_add_index(:users, :email, unique: true)
      end
    end
  end

  describe 'running migration (:up)' do
    it 'creates table, column, and index idempotently' do
      # First run
      run_migration(migration_class, direction: :up)
      expect(table_exists?(:users)).to be true
      expect(column_exists?(:users, :name)).to be true
      expect(column_exists?(:users, :email)).to be true
      expect(index_exists?(:users, :email)).to be true

      # Re-run (idempotent)
      run_migration(migration_class, direction: :up)
      expect(table_exists?(:users)).to be true
      expect(column_exists?(:users, :name)).to be true
      expect(column_exists?(:users, :email)).to be true
      expect(index_exists?(:users, :email)).to be true
    end
  end

  describe 'rolling back migration (:down)' do
    it 'reverses the changes made during :up' do
      # Run :up
      run_migration(migration_class, direction: :up)
      expect(table_exists?(:users)).to be true
      expect(column_exists?(:users, :email)).to be true
      expect(index_exists?(:users, :email)).to be true

      # Run :down
      run_migration(migration_class, direction: :down)
      expect(table_exists?(:users)).to be false
    end
  end

  describe 'unsafe behavior with pre-existing table' do
    before do
      ActiveRecord::Base.connection.drop_table(:users) if table_exists?(:users)
      # Create a users table before running migration
      ActiveRecord::Base.connection.create_table(:users) do |t|
        t.string :pre_existing_column
      end
    end

    it 'skips safe_create_table but still drops table on rollback' do
      expect(table_exists?(:users)).to be true
      expect(column_exists?(:users, :pre_existing_column)).to be true

      # Run :up (safe_create_table skips, but others execute)
      run_migration(migration_class, direction: :up)
      expect(table_exists?(:users)).to be true
      expect(column_exists?(:users, :pre_existing_column)).to be true
      expect(column_exists?(:users, :email)).to be true
      expect(index_exists?(:users, :email)).to be true

      # Run :down (unsafe: drops pre-existing table)
      run_migration(migration_class, direction: :down)
      expect(table_exists?(:users)).to be false # Pre-existing table dropped!
    end
  end
end
