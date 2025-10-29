# SafeMigrations

G'day, mate! Welcome to **SafeMigrations**, a ripper of a gem that makes your Rails migrations as safe as a kangaroo in the outback. With `safe_` prefixed methods, this gem ensures your database schema changes are idempotent—no dramas if you run 'em twice. Built to play nice with Rails' `CommandRecorder`, it auto-reverses your migrations in the `change` method, so you can crack on with building your app without worrying about dodgy rollbacks.

[![Gem Version](https://badge.fury.io/rb/safe_migrations.svg)](https://badge.fury.io/rb/safe_migrations)
[![CI](https://github.com/moskvin/safe_migrations/actions/workflows/ci.yml/badge.svg)](https://github.com/moskvin/safe_migrations/actions)

## Why SafeMigrations?

Tired of migrations chucking a wobbly when tables or columns already exist? SafeMigrations wraps Rails migration methods with `safe_` prefixes (e.g., `safe_create_table`, `safe_add_column`) to check for existing schema elements before making changes. It hooks into Rails' `CommandRecorder` for automatic reversals in `change`-based migrations, keeping your database fair dinkum. 
**Warning**: Since it uses `CommandRecorder`, rollbacks may affect pre-existing schema elements—use with care or chuck in a `reversible` block for complex stuff.

## Features

- **Idempotent Migrations**: `safe_create_table`, `safe_add_column`, `safe_add_index`, and more only run if needed.
- **Auto-Reversal**: Integrates with Rails' `CommandRecorder` to invert `safe_` methods (e.g., `safe_create_table` → `safe_drop_table`) in `change` rollbacks.
- **Rails 7.2+ Ready**: Built for ActiveRecord 7.2, with support for modern Ruby 3.2.
- **Aussie Spirit**: Crafted with a bit of outback grit to keep your migrations smooth as a cold one on a summer arvo.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'safe_migrations'
```

Then give it a burl:

```bash
$ bundle install
```

Or install it yourself faster than a dingo nicks your lunch:

```bash
$ gem install safe_migrations
```

## Usage

Use `safe_` methods in your Rails migrations’ `change` block, and let Rails’ `CommandRecorder` handle the rollback. Here’s a cracking example:

```ruby
class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    safe_create_table(:users) do |t|
      t.string :name
      t.string :email
      t.timestamps
    end
    safe_add_column(:users, :role, :string, default: 'user')
    safe_add_index(:users, :email, unique: true)
  end
end
```

- **Running**: `rails db:migrate` creates the table, column, and index only if they don’t exist.
- **Rolling Back**: `rails db:rollback` inverts to `safe_drop_table`, `safe_remove_column`, `safe_remove_index` (in reverse order).
- **Heads Up**: If a table exists before the migration, `safe_create_table` skips it, but rollback may still call `safe_drop_table`. For critical cases, use `reversible`:

## Development

No worries, mate! To get started:

1. Clone the repo and run `bin/setup` to install dependencies.
2. Run `rake spec` to give the tests a fair go.
3. Use `bin/console` for an interactive prompt to muck around with the code.

To install the gem locally:

```bash
$ bundle exec rake install
```

To release a new version:
1. Update the version in `lib/safe_migrations/version.rb`.
2. Run `bundle exec rake release` to tag the version, push to Git, and ship the gem to [RubyGems.org](https://rubygems.org).

## Testing

The gem includes an RSpec suite to ensure your migrations are as solid as Uluru:

```bash
$ rake spec
```

Tests check idempotency (re-running migrations) and rollback behavior. Note the `CommandRecorder` limitation: pre-existing tables may get dropped on rollback. See `spec/migration_spec.rb` for details.

## Contributing

Got a ripper idea or found a bug? Chuck us a pull request or bug report on GitHub at https://github.com/moskvin/safe_migrations. We’re keen as mustard to make this gem top-notch!

## License

This gem is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgements

Built with a nod to the Aussie spirit—because who doesn’t love a bit of fair dinkum coding? Cheers to the Rails community for the migration framework that makes this possible.

Crack on and make your migrations safe as, mate!
