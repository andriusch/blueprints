module Blueprints
  class Plan
    cattr_reader :plans
    cattr_accessor :executed_plans
    @@plans = {}
    @@executed_plans = Set.new
    @@global_executed_plans = Set.new

    @@global_context = Module.new
    @@context = nil

    def self.setup
      @@context = YAML.load(@@global_context)
      @@executed_plans = @@global_executed_plans.clone
    end

    def self.copy_ivars(to)
      @@context.instance_variables.each do |iv|
        to.instance_variable_set(iv, @@context.instance_variable_get(iv))
      end
    end

    def self.prebuild(plans)
      @@context = @@global_context
      @@global_scenarios = Plan.build(plans) if plans
      @@global_executed_plans = @@executed_plans
      @@global_context = YAML.dump(@@global_context)
    end

    def self.build(*names)
      names.map {|name| @@plans[name.to_sym] or raise PlanNotFoundError, name}.each {|p| p.build}
    end

    # Instance

    attr_reader :name

    def initialize(scenario, &block)
      @name, @parents = parse_name(scenario)
      @block = block

      @@plans[@name] = self
    end

    def build
      build_parent_plans(@@context)
      build_plan(@@context)   
    end

    protected

    def parse_name(name)
      case name
        when Hash
          return name.keys.first.to_sym, [name.values.first].flatten.map{|sc| parse_name(sc).first}
        when Symbol, String
          return name.to_sym, []
        else
          raise TypeError, "Pass plan names as strings or symbols only, cannot build plan #{name.inspect}"
      end
    end

    def say(*messages)
      puts messages.map { |message| "=> #{message}" }
    end

    def build_plan(context)
      surface_errors do
        if @block
          result = context.module_eval(&@block)
          iv_name = :"@#{@name}"
          context.instance_variable_set(iv_name, result) unless context.instance_variable_get(iv_name)
        end
      end unless @@executed_plans.include?(@name)
      @@executed_plans << @name
    end

    def build_parent_plans(context)
      @parents.each do |p|
        parent = @@plans[p] or raise PlanNotFoundError, p

        parent.build_parent_plans(context)
        parent.build_plan(context)
      end
    end

    def surface_errors
      yield
    rescue StandardError => error
      puts
      say "There was an error building scenario '#{@name}'", error.inspect
      puts
      puts error.backtrace
      puts
      raise error
    end
  end
end