module Kernel
  # Useful for wrapping object into a delegator
  # without breaking a chain.
  def wrap_with(klass)
    klass.new(self)
  end

end
