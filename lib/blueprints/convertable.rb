module Blueprints
  module Convertable
    def persist(str)
      File.open(@output_file, 'a+') do |f|
        f.write(str)
      end
    end
    
    def process!
      persist "#{banner_start}#{convert}#{banner_end}"
    end
    
    def banner_start
      "### blueprints from #{@format}\n\n"
    end
    
    def banner_end
      "\n###\n" 
    end
  end

  class Converter
    def self.for(format, options = {})
      require "blueprints/convertable/#{format}"
      Class.new("Blueprints::#{format.capitalize}Converter".constantize) do |options|
        include Convertable
      end
    end
  end
end
