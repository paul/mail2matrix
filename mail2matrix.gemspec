# frozen_string_literal: true

$LOAD_PATH.append File.expand_path("lib", __dir__)
require "mail2matrix/identity"

Gem::Specification.new do |spec|
  spec.name = Mail2Matrix::Identity.name
  spec.version = Mail2Matrix::Identity.version
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Paul Sadauskas"]
  spec.email = ["paul@sadauskas.com"]
  spec.homepage = "https://github.com/paul/mail2matrix"
  spec.summary = ""
  spec.license = "MIT"

  spec.metadata = {
    "source_code_uri" => "https://github.com/paul/mail2matrix",
    "changelog_uri" => "https://github.com/paul/mail2matrix/blob/master/CHANGES.md",
    "bug_tracker_uri" => "https://github.com/paul/mail2matrix/issues"
  }

  spec.required_ruby_version = "~> 2.5"
  spec.add_dependency "dry-configurable", "~> 0.9.0"
  spec.add_dependency "inifile", "~> 3.0.0"
  spec.add_dependency "matrix_sdk", "~> 1.5.0"
  spec.add_dependency "redcarpet", "~> 3.5.0"
  spec.add_dependency "runcom", "~> 5.0"
  spec.add_dependency "thor", "~> 0.20"
  spec.add_development_dependency "bundler-audit", "~> 0.6"
  spec.add_development_dependency "gemsmith", "~> 13.7"
  spec.add_development_dependency "git-cop", "~> 3.5"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "pry", "~> 0.12"
  spec.add_development_dependency "pry-byebug", "~> 3.7"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "reek", "~> 5.4"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "rubocop", "~> 0.73"
  spec.add_development_dependency "rubocop-performance", "~> 1.4"
  spec.add_development_dependency "rubocop-rspec", "~> 1.33"

  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.executables << "mail2matrix"
  spec.require_paths = ["lib"]
end
