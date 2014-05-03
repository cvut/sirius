require 'enum'

class Parity
  extend Enum

  PARITIES = [:both, :odd, :even]

  BOTH = PARITIES[0]
  ODD = PARITIES[1]
  EVEN = PARITIES[2]

  # values method for Enum module
  def self.values
    PARITIES
  end
end