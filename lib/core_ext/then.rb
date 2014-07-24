# Some monkey patches extracted from MethodChain library
# https://github.com/gregwebs/methodchain
module Kernel

  private
    # A middleman for passing code as data in 2 different ways
    # * use a Symbol or an Array as the argument list for send
    # * evaluate a Proc-like object with yield_or_eval
    #
    # Symbol | [Method, *MethodArguments] | (to_proc -> Proc)
    def send_as_function arg
      case arg
      when Symbol then __send__ arg
      when Array then __send__(*arg)
      else yield_or_eval(&arg)
      end
    end

    # invoke send_as_function multiple times, returns self
    # *Message -> self
    def send_as_functions *args
      args.each {|arg| send_as_function arg}
      self
    end

    # yield self or instance_eval based on the block arity
    def yield_or_eval &block
      case block.arity
      # ruby bug for -1
      when 0, -1 then instance_eval(&block)
      when 1 then yield(self)
      else raise ArgumentError, "too many arguments required by block"
      end
    end

  public
    # return self if self or any of the +guards+ evaluate to false,
    # otherwise return the evaluation of the block
    def then *guards, &block
      if guards.empty?
        return self if not self
      else
        guards.each do |cond|
          return self if not (send_as_function cond)
        end
      end

      block_given? ? yield_or_eval(&block) : self
    end

    def then_if(*args, &block)
      if args.all?
        self.then(&block)
      else
        self
      end
    end
end
