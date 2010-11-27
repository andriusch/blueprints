Root = Pathname.new(__FILE__).dirname.join('..', '..')
$: << Root.to_s

require 'rspec'
require 'lib/blueprints'
require 'spec/unit/fixtures'

RSpec.configure do |config|
  config.mock_with :mocha

  config.before do
    Blueprints::Namespace.root.eval_context = Blueprints::EvalContext.new
  end

  config.after do
    Blueprints::Namespace.root.instance_variable_get(:@children).clear
    Blueprints::Namespace.root.executed_blueprints.clear
  end
end
