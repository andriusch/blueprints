module Blueprints
  class ModelGenerator < Rails::Generators::NamedBase
    argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

    def create_blueprint
      blueprint = "#{class_name}.blueprint :#{singular_name}"
      attributes.each do |attribute|
        blueprint << ", :#{attribute.name} => #{default_for(attribute)}"
      end

      dir = File.exists?('spec') ? 'spec' : 'test'
      file = "#{dir}/blueprint.rb"
      create_file file unless File.exists?(file)
      append_file file, "#{blueprint}\n"
    end

    private

    def default_for(attribute)
      if attribute.reference?
        "d(:#{attribute.name})"
      else
        attribute.default.inspect
      end
    end
  end
end

Rails::Generators.hide_namespace(:blueprints)
