Fabricator(:timetable_slot) do
  day Sirius::Day::MONDAY #:monday
  parity :both
  first_hour 1
  duration 2
  room
  parallel
end