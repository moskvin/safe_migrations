# SafeMigrations

G'day, mate! Welcome to **SafeMigrations**, a ripper of a gem that makes your Rails migrations as safe as a kangaroo in the outback. With `safe_` prefixed methods, this gem ensures your database schema changes are idempotent—no dramas if you run 'em twice. Built to play nice with Rails' `CommandRecorder`, it auto-reverses your migrations in the `change` method, so you can crack on with building your app without worrying about dodgy rollbacks.

![safe_migrations](./logo.jpeg)

[![Gem Version](https://badge.fury.io/rb/safe_migrations.svg)](https://badge.fury.io/rb/safe_migrations)
[![CI](https://github.com/moskvin/safe_migrations/actions/workflows/ci.yml/badge.svg)](https://github.com/moskvin/safe_migrations/actions)

## Why SafeMigrations?

Tired of migrations chucking a wobbly when tables or columns already exist? SafeMigrations wraps Rails migration methods with `safe_` prefixes (e.g., `safe_create_table`, `safe_add_column`) to check for existing schema elements before making changes. It hooks into Rails' `CommandRecorder` for automatic reversals in `change`-based migrations, keeping your database fair dinkum. 
**Warning**: Since it uses `CommandRecorder`, rollbacks may affect pre-existing schema elements—use with care or chuck in a `reversible` block for complex stuff.

## Features

- **Idempotent Migrations**: `safe_create_table`, `safe_add_column`, `safe_add_index`, and more only run if needed.
- **Auto-Reversal**: Integrates with Rails' `CommandRecorder` to invert `safe_` methods (e.g., `safe_create_table` → `safe_drop_table`) in `change` rollbacks.
- **Rails 7.0+ Ready**: Built for ActiveRecord 7.0, with support for modern Ruby 3.2.
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

### Dry runs (v1.1+)

Declare `dry_runnable` once to wrap the entire upward migration automatically:

```ruby
class CleanupBrokenLinks < ActiveRecord::Migration[8.0]
  dry_runnable

  def up
    # All database writes here run normally
    Link.where(broken: true).destroy_all 
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
```

```bash
DRY_RUN=1 bundle exec rails db:migrate:up VERSION=20260817090000
# Apply for real:
bundle exec rails db:migrate:up VERSION=20260817090000
```

With `DRY_RUN=1`, the body executes real SQL so counts and reports reflect real work.
An `ActiveRecord::Rollback` then reaches Rails' migration transaction, undoing the
writes and skipping the migration-version record: the migration remains pending.
Unset `DRY_RUN` (or set it to `0` or `false`) for normal execution.

The declaration is inherited and also supports `change` on upward execution;
`down` and reversal of `change` are unaffected. Only opted-in migrations are wrapped.
For existing migrations, the block form remains available:

```ruby
def up
  dry_runnable do
    # Database writes and reporting.
  end
end
```

`dry_run?` exposes the environment flag. Dry runs require Rails' migration runner,
an active transaction, and an adapter supporting DDL transactions (such as PostgreSQL
or SQLite). They reject `disable_ddl_transaction!` and unsupported adapters before
executing the wrapped body. Direct calls to `up` bypass the class-level wrapper.
Do not rescue `ActiveRecord::Rollback` or swallow it in an enclosing transaction
around the block helper: it must reach the migration runner to leave the version pending.

Rollback covers writes on the migration connection, not API calls, files, Ruby state,
or writes on other database connections. Database sequences may still advance.
Prefer targeting one migration: a full migration run can continue to later migrations
after rollback, and migrations without the option still apply normally.

When moving from an application-defined helper, remove its `dry_runnable` and
`dry_run?` definitions so the gem supplies them. Application-specific helpers such
as PaperTrail's `setup_version` stay in the application.

## Development

No worries, mate! To get started:

1. Clone the repo and run `bin/setup` to install dependencies.
2. Run `rake spec` to give the tests a fair go.
3. Use `bin/console` for an interactive prompt to muck around with the code.

To install the gem locally:

```bash
$ bundle exec rake install
```

To release a new version, update `lib/safe_migrations/version.rb` and the changelog,
update the lockfile, then commit your changes and run:

```bash
bundle exec rake release:guarded
# Equivalent:
bin/release
```

The helper requires a clean worktree and the default branch (`origin/HEAD`, falling
back to the current branch). It fetches origin, rejects a behind or diverged branch,
and checks that the version tag does not already exist locally or remotely.
It then runs specs and RuboCop, pushes the branch, and invokes Bundler's
`bundle exec rake release` to build, tag, push, and publish to RubyGems.

Use `bin/release --skip-checks` to skip specs and lint while retaining the git and
version checks. `bin/release --help` displays usage without releasing anything.

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
