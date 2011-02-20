require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

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

  data.gsub!("spec_helper", "test_helper")
  data.gsub!("describe Blueprints do", 'class BlueprintsTest < ActiveSupport::TestCase')

  # lambda {
  #   demolish :just_orange
  # }.should raise_error(ArgumentError)
  data.gsub!(/(\s+)lambda \{\n(.*)\n(\s+)\}.should raise_error\((.*)\)/, "\\1assert_raise(\\4) do\n\\2\n\\3end")
  # should =~ => assert_similar
  data.gsub!(/^(\s+)(.*)\.should\s*=~\s*(.*)/, '\1assert_similar(\2, \3)')
  # A.should_not include(B) => assert(!A.include?(B))
  data.gsub!(/^(\s+)(.*)\.should_not\s*include\((.*)\)/, '\1assert(!\2.include?(\3))')
  # A.should include(B) => assert(A.include?(B))
  data.gsub!(/^(\s+)(.*)\.should\s*include\((.*)\)/, '\1assert(\2.include?(\3))')

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

  File.open('test/blueprints_test.rb', 'w') { |f| f.write(data) }
end

task :default => :rspec_to_test do
  commands = [
          ["Unit specs", "rspec -c spec/unit/*_spec.rb"],
          ["Active record integration", "rspec -c spec/blueprints_spec.rb"],
          ["No ORM integration", "rspec -c spec/blueprints_spec.rb", 'none'],
          ["Mongoid integration", "rspec -c spec/blueprints_spec.rb", 'mongoid'],
          ["Mongo mapper integration", "rspec -c spec/blueprints_spec.rb", 'mongo_mapper'],
          ["Test::Unit", "ruby test/blueprints_test.rb"],
          ["Cucumber", "cucumber features/blueprints.feature -f progress"],
  ]

  statuses = commands.collect do |label, command, orm|
    puts "#{label}:"
    ENV['ORM'] = orm
    system command
  end
  exit 1 unless statuses.all? { |status| status }
end
