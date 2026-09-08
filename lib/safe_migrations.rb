# frozen_string_literal: true

require 'active_record'
require 'safe_migrations/version'
require 'safe_migrations/migration_helper'
require 'safe_migrations/command_recorder_extension'
require 'safe_migrations/dry_run'

module SafeMigrations
  class Error < StandardError; end
  # Your code goes here...
end

ActiveRecord::ConnectionAdapters::AbstractAdapter.include(SafeMigrations::MigrationHelper)
ActiveRecord::Migration.include(SafeMigrations::DryRun)
SafeMigrations::CommandRecorderExtension.apply
