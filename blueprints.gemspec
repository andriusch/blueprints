# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{blueprints}
  s.version = "0.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrius Chamentauskas"]
  s.date = %q{2009-11-27}
  s.description = %q{Another replacement for factories and fixtures. The library that lazy typists will love}
  s.email = %q{sinsiliux@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.rdoc",
     "blueprints.gemspec",
     "init.rb",
     "install.rb",
     "lib/blueprints.rb",
     "lib/blueprints/ar_extensions.rb",
     "lib/blueprints/buildable.rb",
     "lib/blueprints/errors.rb",
     "lib/blueprints/file_context.rb",
     "lib/blueprints/helper.rb",
     "lib/blueprints/namespace.rb",
     "lib/blueprints/plan.rb",
     "lib/blueprints/root_namespace.rb",
     "lib/blueprints/rspec_extensions.rb",
     "lib/blueprints/test_unit_extensions.rb",
     "script/load_schema",
     "script/rspec_to_test",
     "spec/active_record/blueprint.rb",
     "spec/active_record/blueprints_spec.rb",
     "spec/active_record/fixtures/database.yml.example",
     "spec/active_record/fixtures/fruit.rb",
     "spec/active_record/fixtures/schema.rb",
     "spec/active_record/fixtures/tree.rb",
     "spec/active_record/spec_helper.rb",
     "spec/no_db/blueprint.rb",
     "spec/no_db/blueprints_spec.rb",
     "spec/no_db/fixtures/fruit.rb",
     "spec/no_db/spec_helper.rb",
     "test/blueprints_test.rb",
     "test/test_helper.rb",
     "uninstall.rb"
  ]
  s.homepage = %q{http://github.com/sinsiliux/blueprints}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Another replacement for factories and fixtures}
  s.test_files = [
    "spec/no_db/fixtures/fruit.rb",
     "spec/no_db/blueprint.rb",
     "spec/no_db/blueprints_spec.rb",
     "spec/no_db/spec_helper.rb",
     "spec/active_record/fixtures/tree.rb",
     "spec/active_record/fixtures/fruit.rb",
     "spec/active_record/fixtures/schema.rb",
     "spec/active_record/blueprint.rb",
     "spec/active_record/blueprints_spec.rb",
     "spec/active_record/spec_helper.rb",
     "test/test_helper.rb",
     "test/blueprints_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

