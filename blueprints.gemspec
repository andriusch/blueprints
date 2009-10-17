GEM_NAME = "blueprints"
GEM_VERSION = "0.3.0"

Gem::Specification.new do |s|
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.author = "Andrius Chamentauskas"
  s.email = "sinsiliux@gmail.com"
  s.homepage = "http://github.com/sinsiliux/blueprints"
  s.platform = Gem::Platform::RUBY
  s.summary = "Another replacement for factories and fixtures"
  s.description = "Another replacement for factories and fixtures. The library that lazy typists will love"
  s.files = Dir['lib/**/*.rb'] + %w{
    README.rdoc
    LICENSE
  }
  s.require_path = "lib"
  s.test_files = %w{
    spec/no_db/spec_helper.rb
    spec/no_db/blueprints_spec.rb
    spec/no_db/blueprint.rb
    spec/no_db/fixtures/fruit.rb
    spec/active_record/spec_helper.rb
    spec/active_record/blueprints_spec.rb
    spec/active_record/blueprint.rb
    spec/active_record/fixtures/fruit.rb
    spec/active_record/fixtures/tree.rb
    spec/active_record/fixtures/database.yml.example
    spec/active_record/fixtures/schema.rb
    test/test_helper.rb
    test/blueprints_test.rb
  }
  s.has_rdoc = false
  s.add_dependency("activesupport", ">= 2.0.0")
end
