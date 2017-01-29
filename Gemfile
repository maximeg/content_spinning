source "https://rubygems.org"

# Specify your gem's dependencies in content_spinning.gemspec
gemspec

# For Travis
gem "rake"

group :local do
  # Guard
  gem "guard-rspec", require: false
  gem "terminal-notifier-guard", require: false # OS X

  # Perf
  gem "ruby-prof"
end

# Quality
gem "rubocop", ">= 0.30.1", require: false

