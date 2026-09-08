# frozen_string_literal: true

RSpec.describe SafeMigrations::DryRun do
  let(:connection) { ActiveRecord::Base.connection }
  let(:migration_class) do
    Class.new(ActiveRecord::Migration[7.2]) do
      dry_runnable

      def up
        execute 'INSERT INTO dry_run_items (value) VALUES (1)'
      end

      def down
        execute 'DELETE FROM dry_run_items'
      end
    end
  end
  let(:migration) { migration_class.new('DryRunExample', 202609080001) }
  let(:schema_migration) { connection.pool.schema_migration }

  def run(direction = :up)
    ActiveRecord::Migrator.new(direction, [migration], schema_migration,
                               connection.pool.internal_metadata, migration.version).run
  end

  def count
    connection.select_value('SELECT COUNT(*) FROM dry_run_items').to_i
  end

  around do |example|
    previous = ENV['DRY_RUN']
    ENV['DRY_RUN'] = '1'
    example.run
  ensure
    previous.nil? ? ENV.delete('DRY_RUN') : ENV['DRY_RUN'] = previous
  end

  before { connection.create_table(:dry_run_items) { |t| t.integer :value } }
  after do
    connection.drop_table(:dry_run_items)
    schema_migration.delete_version(migration.version.to_s)
  end

  it 'rolls back real writes, leaves the version pending, and can subsequently apply' do
    expect(migration).to receive(:execute).with(/INSERT/).twice.and_wrap_original do |method, *args|
      method.call(*args)
      expect(count).to eq(1)
    end
    run
    expect(count).to eq(0)
    expect(schema_migration.versions).not_to include(migration.version.to_s)

    ENV.delete('DRY_RUN')
    run
    expect(count).to eq(1)
    expect(schema_migration.versions).to include(migration.version.to_s)
  end

  it 'wraps change and rolls back schema changes' do
    migration_class.send(:define_method, :change) { add_column :dry_run_items, :extra, :string }
    run
    expect(connection.column_exists?(:dry_run_items, :extra)).to be false
    expect(schema_migration.versions).not_to include(migration.version.to_s)
  end

  it 'does not wrap down' do
    ENV.delete('DRY_RUN')
    run
    ENV['DRY_RUN'] = '1'
    run(:down)
    expect(count).to eq(0)
    expect(schema_migration.versions).not_to include(migration.version.to_s)
  end

  it 'does not opt unrelated migrations in' do
    migration_class.safe_migrations_dry_runnable = false
    run
    expect(count).to eq(1)
    expect(schema_migration.versions).to include(migration.version.to_s)
  end

  it 'inherits the declaration' do
    expect(Class.new(migration_class).safe_migrations_dry_runnable).to be true
    expect(ActiveRecord::Migration.safe_migrations_dry_runnable).to be false
  end

  it 'supports the existing block form without a class declaration' do
    migration_class.safe_migrations_dry_runnable = false
    migration_class.send(:define_method, :up) do
      dry_runnable { execute 'INSERT INTO dry_run_items (value) VALUES (1)' }
    end
    run
    expect(count).to eq(0)
    expect(schema_migration.versions).not_to include(migration.version.to_s)
  end

  it 'rejects disabled transactions before any writes' do
    migration_class.disable_ddl_transaction!
    expect { run }.to raise_error(StandardError, /DDL transactions/)
    expect(count).to eq(0)
  end

  it 'rejects adapters without DDL transactions before any writes' do
    allow(connection).to receive(:supports_ddl_transactions?).and_return(false)
    expect { run }.to raise_error(StandardError, /DDL transactions/)
    expect(count).to eq(0)
  end

  it 'rejects execution without an outer transaction before any writes' do
    expect { migration.migrate(:up) }.to raise_error(SafeMigrations::Error, /active migration transaction/)
    expect(count).to eq(0)
  end

  it 'propagates migration errors and rolls back their writes' do
    migration_class.send(:define_method, :up) do
      execute 'INSERT INTO dry_run_items (value) VALUES (1)'
      raise 'cleanup failed'
    end
    expect { run }.to raise_error(StandardError, /cleanup failed/)
    expect(count).to eq(0)
    expect(schema_migration.versions).not_to include(migration.version.to_s)
  end

  it 'casts the environment flag without caching stale values' do
    [nil, '', '0', 'false', 'FALSE', 'off'].each do |value|
      ENV['DRY_RUN'] = value
      expect(migration.dry_run?).to be false
    end
    %w[1 true].each do |value|
      ENV['DRY_RUN'] = value
      expect(migration.dry_run?).to be true
    end
  end

  it 'returns the block result during normal execution' do
    ENV.delete('DRY_RUN')
    expect(migration.dry_runnable { :done }).to eq(:done)
  end
end
