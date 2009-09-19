module Test
  module Unit
    class TestCase
      def run_with_blueprints(result, &progress_block)
        Blueprints.setup(self)
        run_without_blueprints(result, &progress_block)
        Blueprints.teardown
      end

      def self.enable_blueprints(options = {})
        include Blueprints::Helper
        Blueprints.load(options)
        alias_method_chain :run, :blueprints
      end
    end
  end
end