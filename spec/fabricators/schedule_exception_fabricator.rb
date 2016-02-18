require 'models/schedule_exception'

Fabricator(:schedule_exception) do
  exception_type Sirius::ScheduleExceptionType::CANCEL
end

Fabricator(:teacher_change_schedule_exception) do
  exception_type Sirius::ScheduleExceptionType::TEACHER_CHANGE
  options({ 'teacher_ids' => '{dude}' })
end
