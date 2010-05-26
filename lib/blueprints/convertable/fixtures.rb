module Blueprints
  class FixturesConverter
    def initialize(options = {})
      @format = "fixtures"
      @source_files = options[:source_files]
      @output_file = options[:output_file]
      @blueprints_data = ""
      
      raise "No source files given" unless @source_files
      raise "No output file given" unless @output_file
    end
    
    def convert
      @source_files.each do |fixture_file|
        klass = File.basename(fixture_file, '.yml').singularize.capitalize

        loaded_yaml = YAML.load(File.read(fixture_file))

        @blueprints_data = loaded_yaml.collect do |title,yaml_obj|
          params = yaml_obj.collect do |k,v|
            ":#{k} => #{parameterize(v)}"
          end.join(', ')

          "#{klass}.blueprint(:#{title}, {#{params}})\n"
        end
      end
      
      @blueprints_data
    end

    def parameterize(object)
      if object =~ /<%=\s+?(.+)\s+%>/
        '('+$1+')'
      elsif object.is_a?(String)
        (%Q(#{object})).inspect
      elsif object.nil?
        'nil'
      else
        object.to_s
      end
    end
  end
end