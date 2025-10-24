# frozen_string_literal: true

require 'active_record'
require 'safe_migrations/version'
require 'safe_migrations/migration_helper'
require 'safe_migrations/command_recorder_extension'

module SafeMigrations
  class Error < StandardError; end
  # Your code goes here...
end

ActiveRecord::ConnectionAdapters::AbstractAdapter.include(SafeMigrations::MigrationHelper)
SafeMigrations::CommandRecorderExtension.apply
