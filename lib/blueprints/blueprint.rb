module Blueprints
  # Class for actual blueprints. Allows building itself by executing block passed against current context.
  class Blueprint < Buildable
    # Initializes blueprint by name, context and block. Also sets default demolish and update blocks.
    # @param name (see Buildable#initialize)
    # @param context (see Buildable#initialize)
    def initialize(name, context, &block)
      super(name, context)

      ivname = variable_name
      @block = block
      @demolish_block = Proc.new { instance_variable_get(ivname).destroy }
      @update_block = Proc.new { instance_variable_get(ivname).blueprint(options) }
    end

    # Returns whether blueprint was ever used
    # @return [true, false] True if blueprint was used, false otherwise.
    def used?
      @used
    end

    # Builds blueprint and adds it to executed blueprint array. Setups instance variable with same name as blueprint if it is not defined yet.
    # Marks blueprint as used.
    # @param eval_context (see Buildable#build)
    # @param build_once (see Buildable#build)
    # @param options (see Buildable#build)
    def build_self(eval_context, build_once, options)
      @used = true
      surface_errors do
        if built? and build_once
          eval_context.instance_eval(@context, options, &@update_block) if options.present?
        elsif @block
          result(eval_context) { eval_context.instance_eval(@context, options, &@block) }
        end
      end
    end

    # Changes blueprint block to build another blueprint by passing additional options to it. Usually used to dry up
    # blueprints that are often built with some options.
    # @example Extending blueprints
    #   Post.blueprint :post, :title => 'hello blueprints'
    #   blueprint(:published_post).extends(:post, :published_at => Time.now)
    # @param [Symbol, String] parent Name of parent blueprint.
    # @param [Hash] options Options to be passed when building parent.
    def extends(parent, options)
      attributes(options)
      @block = Proc.new { build parent => attributes }
    end

    # Changes backtrace to include what blueprint was being built.
    # @param [Array<String>] trace Current trace
    # @return [Array<String>] Changed trace with included currently built blueprint name.
    def backtrace(trace)
      trace.collect! { |line| line.sub(/^#{@context.file}:(\d+).*/, "#{@context.file}:\\1:in blueprint '#{@name}'") }
    end

    # @overload demolish(&block)
    #   Sets custom block for demolishing this blueprint.
    # @overload demolish(eval_context)
    #   Demolishes blueprint by calling demolish block.
    #   @param [Blueprints::EvalContext] eval_context Context where blueprint was built in.
    #   @raise [Blueprints::DemolishError] If blueprint has not been built yet.
    def demolish(eval_context = nil, &block)
      if block
        @demolish_block = block
      elsif eval_context and built?
        eval_context.instance_eval(@context, {}, &@demolish_block)
        undo!
      else
        raise DemolishError, @name
      end
    end

    # Allows customizing what happens when blueprint is already built and it's being built again.
    def update(&block)
      @update_block = block
    end

    private

    def surface_errors
      yield
    rescue StandardError => error
      backtrace(error.backtrace)
      raise error
    end
  end
end
