# Module that gets included into RSpec Configuration class to provide enable_blueprints method.
module Blueprints::RspecMixin
  # Enables blueprints in rspec. Is automatically added if <tt>Spec</tt> is defined at loading time or <tt>script/spec</tt>
  # is used. You might need to require it manually in certain case (eg. running specs from metrics).
  # Accepts options hash. For supported options please check Blueprints.load.
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

if defined?(RSpec)
  module RSpec #:nodoc:
    module Core #:nodoc:
      class Configuration
        include  Blueprints::RspecMixin
      end
    end
  end
else
  module Spec #:nodoc:
    module Runner #:nodoc:
      class Configuration
        include Blueprints::RspecMixin
      end
    end
  end
end
