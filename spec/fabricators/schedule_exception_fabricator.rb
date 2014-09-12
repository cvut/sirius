require 'models/schedule_exception'

Fabricator(:schedule_exception) do
  exception_type Sirius::ScheduleExceptionType::CANCEL
end
