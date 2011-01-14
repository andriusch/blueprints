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
  s.default_executable = %q{blueprintify}
  s.homepage = %q{http://github.com/sinsiliux/blueprints}
  s.summary = %q{Awesome replacement for factories and fixtures}
  s.description = %q{Awesome replacement for factories and fixtures that focuses on being DRY and making developers type as little as possible.}

  s.executables = ["blueprintify"]
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"

  s.add_runtime_dependency(%q<activesupport>, [">= 2.3.0"])
  s.add_runtime_dependency(%q<database_cleaner>, ["~> 0.5.0"])
  s.add_development_dependency(%q<rspec>, ["~> 2.2.0"])
  s.add_development_dependency(%q<mysql2>)
  s.add_development_dependency(%q<activerecord>, [">= 2.3.0"])
  s.add_development_dependency(%q<bson_ext>, [">= 1.1.4"])
  s.add_development_dependency(%q<mongoid>, [">= 2.0.0.beta"])
  s.add_development_dependency(%q<mongo_mapper>, [">= 0.8.0"])
  s.add_development_dependency(%q<dm-migrations>, [">= 1.0.0"])
  s.add_development_dependency(%q<dm-transactions>, [">= 1.0.0"])
  s.add_development_dependency(%q<dm-mysql-adapter>, [">= 1.0.0"])
  s.add_development_dependency(%q<mocha>, [">= 0.9.8"])
  s.add_development_dependency(%q<shoulda>, [">= 2.10.0"])
  s.add_development_dependency(%q<cucumber>, [">= 0.7.0"])
  s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
end

