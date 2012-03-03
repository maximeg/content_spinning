$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "content_spinning/version"

Gem::Specification.new do |s|
  s.name        = "content_spinning"
  s.version     = ContentSpinning::Version::STRING
  s.date        = Time.now.strftime('%Y-%m-%d')

  s.authors     = ["Maxime Garcia"]
  s.email       = ["maxime.garcia@maxbusiness.fr"]

  s.summary     = "Content Spinning"
  s.homepage    = "http://github.com/maximeg/content_spinning"

  s.files       = %w( README.md LICENSE )
  s.files      += Dir.glob("lib/**/*")
  s.require_paths = ["lib"]
  s.test_files  = Dir.glob("spec/**/*")
  s.has_rdoc    = false

  s.add_development_dependency 'rspec', '~> 2.8'
  s.add_development_dependency 'guard-rspec'

  s.description = <<description
    To spin some text, mainly for SEO purpose.

    Spinning the string "Hi {there|you}! I'm {efficient|productive}." gives
    these four strings :

    * Hi there! I'm efficient.
    * Hi there! I'm productive.
    * Hi you! I'm efficient.
    * Hi you! I'm productive.
description
end

