require 'methodchain'

module Kernel
  def then_if(*args, &block)
    if args.all?
      self.then(&block)
    else
      self
    end
  end
end
