# frozen_string_literal: true
require "bundler"
Bundler.setup

require "rake"
require "rspec/core/rake_task"

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "content_spinning/version"
VERSION = ContentSpinning::Version::STRING

task gem: :build
task :build do
  system "gem build content_spinning.gemspec"
end

task release: :build do
  system "git tag -a #{VERSION} -m 'Version #{VERSION}'"
  system "git push --tags"
  system "gem push content_spinning-#{VERSION}.gem"
end

RSpec::Core::RakeTask.new("spec") do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

RSpec::Core::RakeTask.new("spec:progress") do |spec|
  spec.rspec_opts = %w(--format progress)
  spec.pattern = "spec/**/*_spec.rb"
end

task default: :spec
