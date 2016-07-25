require 'models/schedule_exception'

Fabricator(:schedule_exception) do
  exception_type 'cancel'
  name 'Cancelling schedule exception'
end

Fabricator(:teacher_change_schedule_exception) do
  exception_type 'teacher_change'
  name 'Teacher change schedule exception'
  options({ 'teacher_ids' => '{dude}' })
end
