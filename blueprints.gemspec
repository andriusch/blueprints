GEM_NAME = "blueprints"
GEM_VERSION = "0.2.4"

Gem::Specification.new do |s|
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.authors = ["Andrius Chamentauskas"]
  s.email = "sinsiliux@gmail.com"
  s.homepage = "http://github.com/sinsiliux/blueprints"
  s.platform = Gem::Platform::RUBY
  s.summary = "Another replacement for factories and fixtures"
  s.files = %w{
    lib/blueprints.rb
    lib/blueprints/errors.rb
    lib/blueprints/file_context.rb
    lib/blueprints/helper.rb
    lib/blueprints/plan.rb
    lib/blueprints/ar_extensions.rb
    lib/blueprints/rspec_extensions.rb
    lib/blueprints/test_unit_extensions.rb
    README.rdoc
    LICENSE
  }
  s.require_path = "lib"
  s.test_files = %w{
    spec/no_db/spec_helper.rb
    spec/no_db/blueprints_spec.rb
    spec/no_db/blueprints.rb
    spec/no_db/fixtures/fruit.rb
    spec/active_record/spec_helper.rb
    spec/active_record/blueprints_spec.rb
    spec/active_record/blueprints.rb
    spec/active_record/fixtures/fruit.rb
    spec/active_record/fixtures/tree.rb
    spec/active_record/fixtures/database.yml.example
    spec/active_record/fixtures/schema.rb
    test/test_helper.rb
    test/blueprints_test.rb
  }
  s.has_rdoc = false
  s.add_dependency("activerecord", ">= 2.0.0")
end
