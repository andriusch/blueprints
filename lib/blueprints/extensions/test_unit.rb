module Test #:nodoc:
  module Unit #:nodoc:
    class TestCase
      # Runs tests with blueprints support
      def run_with_blueprints(result, &progress_block)
        Blueprints.setup(self)
        run_without_blueprints(result, &progress_block)
        Blueprints.teardown
      end

      # Enables blueprints in test/unit. Is automatically added if <tt>Spec</tt> is not defined at loading time.
      # You might need to require it manually in certain case (eg. using both rspec and test/unit).
      # Accepts options hash. For supported options please check Blueprints.load.
      def self.enable_blueprints(options = {})
        include Blueprints::Helper
        Blueprints.load(options)
        alias_method_chain :run, :blueprints
      end
    end
  end
end
