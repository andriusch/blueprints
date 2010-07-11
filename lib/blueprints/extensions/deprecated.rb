module EnableBlueprints
  def enable_blueprints(options = {})
    puts "DEPRECATION WARNING: enable_blueprints is deprecated. Use Blueprints.enable"
    Blueprints.enable do |config|
      options.each {|option, value| config.send("#{option}=", value) }
    end
  end
end

ActiveSupport::TestCase.send(:include, EnableBlueprints) if defined? ActiveSupport::TestCase
Spec::Runner::Configuration.send(:include, EnableBlueprints) if defined? Spec or $0 =~ /script.spec$/
