# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in safe_migrations.gemspec
gemspec

gem 'bundler', '~> 2.7'
gem 'rake', '~> 13.0'
gem 'rubocop'
gem 'rubocop-rake'
gem 'rubocop-rspec'

group :test do
  gem 'rspec', '~> 3.12'
  gem 'sqlite3', '~> 2.7'
end
