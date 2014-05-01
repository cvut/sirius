require 'models/timetable_slot'

Fabricator(:timetable_slot) do
  day Day::MONDAY
  parity :both
  first_hour 1
  duration 2
  room
  parallel
end
