Dir.glob('blueprints/convertable/*').each do |f|
  puts "Woowoo: #{f}"
  require f
end

module Blueprints
  module Convertable
    def baner_start
      "### blueprints from #{@format}\n\n"
    end
    
    def banner_end
      "\n\n###" 
    end
    
    def process!
      "#{banner_start}#{convert}#{banner_end}"
    end
  end

  class Converter
    include Convertable
    
    def initialize(format, options = {})
      raise "Please specify format." unless format
      @format = format
      @options = options
      @source_files = Dir.glob(options[:source_files] || '{spec,test}/fixtures/*.yml')
      @output_file = Dir.glob(options[:output_file] || Blueprints::PLAN_FILES.detect{|f|
        File.exists?(f)
      })
      
      raise "No output file detected" unless @output_file
      raise "No input files found" unless @source_files
      str = @format
      self.class.class_eval {
        require "blueprints/convertable/#{str}"
        include "Blueprints::Convertable::#{str.capitalize}".constantize 
      }
    end
    
    def persist
      File.open(@output_file, 'w') do |f|
        f.write(process!)
      end
    end
  end
end

require 'rubygems'
require 'active_support'
require 'blueprints'
require 'convertable/fixtures'
bpc = Blueprints::Converter.new('fixtures', :output_file => '*')

bpc.persist

puts bpc.inspect
puts (bpc.methods - Object.methods).inspect