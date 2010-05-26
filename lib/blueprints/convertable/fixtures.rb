# 1) define sources
# 2) read sources
# 3) convert sources to blueprints
# 4) persist blueprints

module Blueprints
  module Convertable
    module Fixtures
      def convert
        @blueprints_data = ""
      end
    end
  end
end