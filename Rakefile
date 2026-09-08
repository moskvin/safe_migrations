# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :release do
  desc 'Check git, run specs and lint, push the branch, then release to RubyGems'
  task :guarded do
    sh File.expand_path('bin/release', __dir__)
  end
end
