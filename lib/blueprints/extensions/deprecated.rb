module EnableBlueprints #:nodoc:
  def enable_blueprints(options = {})
    STDERR.puts "DEPRECATION WARNING: enable_blueprints is deprecated. Use Blueprints.enable"
    Blueprints.enable do |config|
      options.each {|option, value| config.send("#{option}=", value) }
    end
  end
end

module ActiveSupport #:nodoc:all
  class TestCase
    include EnableBlueprints
  end
end if defined? ActiveSupport::TestCase

module Spec #:nodoc:all
  module Runner
    class Configuration
      include EnableBlueprints
    end
  end
end if defined? Spec or $0 =~ /script.spec$/
