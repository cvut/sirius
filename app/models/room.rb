class Room < Sequel::Model

  one_to_many :events

  ##
  # Return a room with a given kos_code or raise an error
  def self.with_code! kos_code
    first!(id: kos_code)
  end

  def kos_code=(code)
    self.id = code
  end

  def kos_code
    id
  end

  def to_s
    kos_code
  end
end
