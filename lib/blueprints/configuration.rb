module Blueprints
  # Contains configuration of blueprints. Instance of this is yielded in Blueprints.enable block.
  # @example Configuring through Blueprints.enable block
  #   Blueprints.enable do |config|
  #     config.prebuild = :user, :profile
  #   end
  # @example Configuring directly
  #   Blueprints.config.transactions = false
  class Configuration
    # Allows passing custom filename pattern in case blueprints are held in place other than spec/blueprint, test/blueprint, blueprint.
    attr_reader :filename
    # Allows passing scenarios that should be prebuilt and available in all tests. Works similarly to fixtures.
    attr_accessor :prebuild
    # Allows passing custom root folder to use in case of non rails project. Defaults to Rails.root or current folder if Rails is not defined.
    attr_reader :root
    # By default blueprints runs each test in it's own transaction. This may sometimes be not desirable so this options allows to turn this off.
    attr_accessor :transactions
    # Default attributes are used when blueprints has no name specified.
    attr_reader :default_attributes

    # Initializes new Configuration object with default attributes.
    # By defaults filename patterns are: blueprint.rb and blueprint/*.rb in spec, test and root directories.
    # Also by default prebuildable blueprints list is empty, transactions are enabled and root is set to Rails.root or current directory.
    def initialize
      self.filename = [nil, "spec", "test"].map do |dir|
        ["blueprint"].map do |file|
          path = File.join([dir, file].compact)
          ["#{path}.rb", File.join(path, "*.rb")]
        end
      end.flatten
      @prebuild = []
      @transactions = true
      @root = defined?(Rails) ? Rails.root : Pathname.pwd
      @default_attributes = [:name]
    end

    def filename=(value)
      @filename = Array(value).flatten.collect {|path| Pathname.new(path) }
    end

    def root=(value)
      @root = Pathname.new(value)
    end

    def default_attributes=(value)
      @default_attributes = Array(value)
    end
  end
end
