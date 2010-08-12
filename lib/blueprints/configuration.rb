module Blueprints
  class Configuration
    SUPPORTED_ORMS = [nil, :active_record]
    # Allows passing custom filename pattern in case blueprints are held in place other than spec/blueprint, test/blueprint, blueprint.
    attr_reader :filename
    # Allows passing scenarios that should be prebuilt and available in all tests. Works similarly to fixtures.
    attr_accessor :prebuild
    # Allows passing custom root folder to use in case of non rails project. Defaults to RAILS_ROOT or current folder if RAILS_ROOT is not defined.
    attr_reader :root
    # By default blueprints runs each test in it's own transaction. This may sometimes be not desirable so this options allows to turn this off.
    attr_accessor :transactions

    # Sets default attributes for all attributes
    def initialize
      self.filename = [nil, "spec", "test"].map do |dir|
        ["blueprint"].map do |file|
          path = File.join([dir, file].compact)
          ["#{path}.rb", File.join(path, "*.rb")]
        end
      end.flatten
      @orm = :active_record
      @prebuild = []
      @transactions = true
      @root = defined?(Rails) ? Rails.root : Pathname.pwd
    end

    def filename=(value)
      @filename = Array(value).flatten.collect {|path| Pathname.new(path) }
    end

    def root=(value)
      @root = Pathname.new(value)
    end
  end
end
