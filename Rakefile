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
