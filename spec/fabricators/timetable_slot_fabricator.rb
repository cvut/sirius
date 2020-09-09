require 'models/timetable_slot'

Fabricator(:timetable_slot, class_name: TimetableSlot) do
  day Day::MONDAY
  parity 'both'
  first_hour 1
  duration 2
  room
  parallel
end

Fabricator(:timetable_slot_with_times, class_name: TimetableSlot) do
  day Day::MONDAY
  parity 'both'
  start_time Time.parse('07:30')
  end_time Time.parse('08:10')
  room
  parallel
end

Fabricator(:timetable_slot_with_weeks, from: :timetable_slot_with_times) do
  parity nil
  weeks [1, 3]
end
