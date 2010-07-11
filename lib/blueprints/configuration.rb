module Blueprints
  class Configuration
    SUPPORTED_ORMS = [nil, :active_record]
    # Allows passing custom filename pattern in case blueprints are held in place other than spec/blueprint, test/blueprint, blueprint.
    attr_accessor :filename
    # Allows passing scenarios that should be prebuilt and available in all tests. Works similarly to fixtures.
    attr_accessor :prebuild
    # Allows passing custom root folder to use in case of non rails project. Defaults to RAILS_ROOT or current folder if RAILS_ROOT is not defined.
    attr_accessor :root
    # By default blueprints runs each test in it's own transaction. This may sometimes be not desirable so this options allows to turn this off.
    attr_accessor :transactions
    # Returns ORM that is used, default is :active_record
    attr_reader :orm

    # Sets default attributes for all attributes
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

    # Allows specifying what ORM should be used. See SUPPORTED_ORMS to check what values it can contain.
    def orm=(value)
      if SUPPORTED_ORMS.include?(value)
        @orm = value
      else
        raise ArgumentError, "Unsupported ORM #{value.inspect}. Blueprints supports only #{SUPPORTED_ORMS.collect(&:inspect).join(', ')}"
      end
    end
  end
end
