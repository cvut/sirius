class Room < Sequel::Model

  one_to_many :events

end
