# Useful for wrapping object into a delegator
# without breaking a chain.
module ObjectWrap
  refine Object do
    def wrap_with(klass)
      klass.new(self)
    end
  end
end
