Fabricator(:timetable_slot) do
  day :monday
  parity :both
  first_hour 1
  duration 2
  room
  parallel
end