# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{blueprints}
  s.version = "0.8.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrius Chamentauskas"]
  s.date = %q{2010-10-03}
  s.default_executable = %q{blueprintify}
  s.description = %q{Another replacement for factories and fixtures. The library that lazy typists will love}
  s.email = %q{sinsiliux@gmail.com}
  s.executables = ["blueprintify"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "Gemfile",
     "Gemfile.lock",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/blueprintify",
     "blueprints.gemspec",
     "features/blueprints.feature",
     "features/step_definitions/blueprints_steps.rb",
     "features/support/env.rb",
     "init.rb",
     "install.rb",
     "lib/blueprints.rb",
     "lib/blueprints/blueprint.rb",
     "lib/blueprints/buildable.rb",
     "lib/blueprints/configuration.rb",
     "lib/blueprints/context.rb",
     "lib/blueprints/convertable.rb",
     "lib/blueprints/convertable/fixtures.rb",
     "lib/blueprints/core_ext.rb",
     "lib/blueprints/dependency.rb",
     "lib/blueprints/errors.rb",
     "lib/blueprints/extensions/cucumber.rb",
     "lib/blueprints/extensions/rspec.rb",
     "lib/blueprints/extensions/test_unit.rb",
     "lib/blueprints/file_context.rb",
     "lib/blueprints/helper.rb",
     "lib/blueprints/namespace.rb",
     "lib/blueprints/root_namespace.rb",
     "spec/active_record/blueprint.rb",
     "spec/active_record/blueprints_spec.rb",
     "spec/active_record/fixtures/database.yml.example",
     "spec/active_record/fixtures/fruit.rb",
     "spec/active_record/fixtures/schema.rb",
     "spec/active_record/fixtures/tree.rb",
     "spec/active_record/spec_helper.rb",
     "spec/mongoid/blueprint.rb",
     "spec/mongoid/blueprints_spec.rb",
     "spec/mongoid/fixtures/fruit.rb",
     "spec/mongoid/spec_helper.rb",
     "spec/no_db/blueprint.rb",
     "spec/no_db/blueprints_spec.rb",
     "spec/no_db/fixtures/fruit.rb",
     "spec/no_db/spec_helper.rb",
     "spec/test_all.sh",
     "spec/unit/active_record_spec.rb",
     "spec/unit/blueprint_spec.rb",
     "spec/unit/blueprints_spec.rb",
     "spec/unit/buildable_spec.rb",
     "spec/unit/configuration_spec.rb",
     "spec/unit/dependency_spec.rb",
     "spec/unit/fixtures.rb",
     "spec/unit/namespace_spec.rb",
     "spec/unit/spec_helper.rb",
     "test/blueprints_test.rb",
     "test/test_helper.rb",
     "uninstall.rb"
  ]
  s.homepage = %q{http://github.com/sinsiliux/blueprints}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Another replacement for factories and fixtures}
  s.test_files = [
    "spec/mongoid/fixtures/fruit.rb",
     "spec/mongoid/spec_helper.rb",
     "spec/mongoid/blueprints_spec.rb",
     "spec/mongoid/blueprint.rb",
     "spec/no_db/fixtures/fruit.rb",
     "spec/no_db/spec_helper.rb",
     "spec/no_db/blueprints_spec.rb",
     "spec/no_db/blueprint.rb",
     "spec/unit/active_record_spec.rb",
     "spec/unit/blueprint_spec.rb",
     "spec/unit/spec_helper.rb",
     "spec/unit/fixtures.rb",
     "spec/unit/configuration_spec.rb",
     "spec/unit/namespace_spec.rb",
     "spec/unit/blueprints_spec.rb",
     "spec/unit/buildable_spec.rb",
     "spec/unit/dependency_spec.rb",
     "spec/active_record/fixtures/fruit.rb",
     "spec/active_record/fixtures/tree.rb",
     "spec/active_record/fixtures/schema.rb",
     "spec/active_record/spec_helper.rb",
     "spec/active_record/blueprints_spec.rb",
     "spec/active_record/blueprint.rb",
     "test/test_helper.rb",
     "test/blueprints_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.0"])
      s.add_runtime_dependency(%q<database_cleaner>, ["~> 0.5.0"])
      s.add_development_dependency(%q<rspec>, [">= 2.0.0.beta"])
      s.add_development_dependency(%q<activerecord>, [">= 2.3.0"])
      s.add_development_dependency(%q<mongoid>, [">= 2.0.0.beta"])
      s.add_development_dependency(%q<mocha>, [">= 0.9.8"])
      s.add_development_dependency(%q<shoulda>, [">= 2.10.0"])
      s.add_development_dependency(%q<cucumber>, [">= 0.7.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.3.0"])
      s.add_dependency(%q<database_cleaner>, ["~> 0.5.0"])
      s.add_dependency(%q<rspec>, [">= 2.0.0.beta"])
      s.add_dependency(%q<activerecord>, [">= 2.3.0"])
      s.add_dependency(%q<mongoid>, [">= 2.0.0.beta"])
      s.add_dependency(%q<mocha>, [">= 0.9.8"])
      s.add_dependency(%q<shoulda>, [">= 2.10.0"])
      s.add_dependency(%q<cucumber>, [">= 0.7.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.3.0"])
    s.add_dependency(%q<database_cleaner>, ["~> 0.5.0"])
    s.add_dependency(%q<rspec>, [">= 2.0.0.beta"])
    s.add_dependency(%q<activerecord>, [">= 2.3.0"])
    s.add_dependency(%q<mongoid>, [">= 2.0.0.beta"])
    s.add_dependency(%q<mocha>, [">= 0.9.8"])
    s.add_dependency(%q<shoulda>, [">= 2.10.0"])
    s.add_dependency(%q<cucumber>, [">= 0.7.0"])
  end
end

