class ActiveSupport::TestCase
  include Blueprints::Helper
  # Runs tests with blueprints support
  def run_with_blueprints(result, &progress_block)
    Blueprints.setup(self)
    run_without_blueprints(result, &progress_block)
    Blueprints.teardown
  end
  alias_method_chain :run, :blueprints
end
