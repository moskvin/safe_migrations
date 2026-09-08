# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-09-08

### Added

- Class-level `dry_runnable` option to automatically wrap upward `up` and `change` execution.
- `dry_runnable { ... }` block helper and `dry_run?` predicate, controlled by `DRY_RUN`.
- Dry runs execute real database changes, then roll back through Rails' migration transaction and leave the migration pending.
- Guards reject dry runs when DDL transactions are disabled, unsupported, or no transaction is active.

## [1.0.0] - 2025-10-24

### Added
- Initial release of CHANGELOG.md, the all-in-one safe rails migrations.


### Changed
- N/A (initial release)

[1.0.0]: https://github.com/moskvin/safe_migrations/releases/tag/v1.0.0
[1.1.0]: https://github.com/moskvin/safe_migrations/releases/tag/v1.1.0
