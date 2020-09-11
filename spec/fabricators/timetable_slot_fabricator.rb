require 'models/timetable_slot'

Fabricator(:timetable_slot, class_name: TimetableSlot) do
  day Day::MONDAY
  parity 'both'
  first_hour 1
  duration 2
  room
  parallel
end

Fabricator(:timetable_slot_with_weeks, class_name: TimetableSlot) do
  day Day::MONDAY
  parity nil
  first_hour 1
  room
  parallel
  start_time
  end_time
  weeks
end
