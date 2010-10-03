require 'rubygems'
begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "blueprints"
    gemspec.summary = "Another replacement for factories and fixtures"
    gemspec.description = "Another replacement for factories and fixtures. The library that lazy typists will love"
    gemspec.email = "sinsiliux@gmail.com"
    gemspec.homepage = "http://github.com/sinsiliux/blueprints"
    gemspec.authors = ["Andrius Chamentauskas"]
    gemspec.bindir = 'bin'
    gemspec.executables = ['blueprintify']
    gemspec.add_dependency 'activesupport', '>=2.3.0'
    gemspec.add_dependency 'database_cleaner', '~>0.5.0'
    gemspec.add_development_dependency 'rspec', '>=2.0.0.beta'
    gemspec.add_development_dependency 'activerecord', '>=2.3.0'
    gemspec.add_development_dependency 'mongoid', '>=2.0.0.beta'
    gemspec.add_development_dependency 'mocha', '>=0.9.8'
    gemspec.add_development_dependency 'shoulda', '>=2.10.0'
    gemspec.add_development_dependency 'cucumber', '>=0.7.0'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

namespace :db do
  desc "Create database structure"
  task :prepare do
    require 'rubygems'
    require 'active_record'

    Root = Pathname.new(__FILE__).dirname
    require Root.join("spec/support/active_record/initializer")

    load("spec/support/active_record/schema.rb")
  end
end

desc "Convert rspec specs to test/unit tests"
task :rspec_to_test do
  Dir.chdir File.dirname(__FILE__)
  data = IO.read('spec/blueprints_spec.rb')

  data.gsub!("require File.dirname(__FILE__) + '/spec_helper'", "require File.dirname(__FILE__) + '/test_helper'")
  data.gsub!("describe Blueprints do", 'class BlueprintsTest < ActiveSupport::TestCase')

  # lambda {
  #   demolish :just_orange
  # }.should raise_error(ArgumentError)
  data.gsub!(/(\s+)lambda \{\n(.*)\n(\s+)\}.should raise_error\((.*)\)/, "\\1assert_raise(\\4) do\n\\2\n\\3end")
  # should =~ => assert_similar
  data.gsub!(/^(\s+)(.*)\.should\s*=~\s*(.*)/, '\1assert_similar(\2, \3)')
  # A.should_not include(B) => assert_false(A.include?(B))
  data.gsub!(/^(\s+)(.*)\.should_not\s*include\((.*)\)/, '\1assert(!\2.include?(\3))')

  # .should_not => assert(!())
  data.gsub!(/^(\s+)(.*)\.should_not(.*)/, '\1assert(!(\2\3))')
  # .should => assert()
  data.gsub!(/^(\s+)(.*)\.should(.*)/, '\1assert(\2\3)')
  # be_nil => .nil?
  data.gsub!(/ be_([^\(\)]*)/, '.\1?')
  # have(2).items => .size == 2
  data.gsub!(/ have\((\d+)\)\.items/, '.size == \1')

  data.gsub!(/^(\s+)describe/, '\1context')
  data.gsub!(/^(\s+)it (["'])(should )?/, '\1should \2')
  data.gsub!(/^(\s+)before.*do/, '\1setup do')
  data.gsub!(/^(\s+)after.*do/, '\1teardown do')

  File.open('test/blueprints_test.rb', 'w') {|f| f.write(data)}
end
