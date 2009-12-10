module Spec
  module Runner
    class Configuration
      def enable_blueprints(options = {})
        Blueprints.load(options)

        include(Blueprints::Helper)
        before do
          Blueprints.setup(self)
        end
        after do
          Blueprints.teardown
        end
      end
    end
  end
end