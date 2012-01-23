# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/lib/blueprints/version'

Gem::Specification.new do |s|
  s.name = %q{blueprints}
  s.version = Blueprints::VERSION
  s.platform = Gem::Platform::RUBY

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = "blueprints"

  s.authors = ["Andrius Chamentauskas"]
  s.email = %q{sinsiliux@gmail.com}
  s.homepage = %q{http://sinsiliux.github.com/blueprints}
  s.summary = %q{Awesome replacement for factories and fixtures}
  s.description = %q{Awesome replacement for factories and fixtures that focuses on being DRY and making developers type as little as possible.}

  s.executables = ["blueprintify"]
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"

  s.add_runtime_dependency("activesupport", ">= 2.3.0")
  s.add_runtime_dependency("database_cleaner", ">= 0.6.1")
end

