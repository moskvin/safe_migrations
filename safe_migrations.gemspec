# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'safe_migrations/version'

Gem::Specification.new do |spec|
  spec.name          = 'safe_migrations'
  spec.version       = SafeMigrations::VERSION
  spec.authors       = ['Nikolay Moskvin']
  spec.email         = ['nikolay.moskvin@gmail.com']

  spec.summary       = 'Idempotent migration helpers for Rails with safe, reversible operations.'
  spec.description   = "SafeMigrations enhances Rails migrations with safe_ prefixed methods that prevent errors by checking for existing schema elements before execution. It integrates with Rails' CommandRecorder for automatic reversal in change-based migrations, ensuring safe and reliable database schema management."
  spec.homepage      = 'https://github.com/moskvin/safe_migrations'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/moskvin/safe_migrations'
    spec.metadata['changelog_uri'] = 'https://github.com/moskvin/safe_migrations/blob/master/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.2'

  spec.add_dependency 'activerecord', '>= 7.0'

  spec.add_development_dependency 'bundler', '~> 2.7'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
end
