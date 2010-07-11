module Blueprints
  class Configuration
    SUPPORTED_ORMS = [nil, :active_record]
    attr_accessor :filename, :orm, :prebuild, :root, :transactions

    def initialize
      @filename = [nil, "spec", "test"].map do |dir|
        ["blueprint"].map do |file|
          path = File.join([dir, file].compact)
          ["#{path}.rb", File.join(path, "*.rb")]
        end
      end.flatten
      @orm = :active_record
      @prebuild = []
      @transactions = true
      @root = if defined?(RAILS_ROOT)
        RAILS_ROOT
      else
        nil
      end
    end

    def orm=(value)
      if SUPPORTED_ORMS.include?(value)
        @orm = value
      else
        raise ArgumentError, "Unsupported ORM #{value.inspect}. Blueprints supports only #{SUPPORTED_ORMS.collect(&:inspect).join(', ')}"        
      end
    end
  end
end
