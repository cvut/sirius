class Course < Sequel::Model

  one_to_many :parallels
  one_to_many :events

end
