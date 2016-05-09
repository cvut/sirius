require 'sirius_api/semester_day'

Fabricator(:semester_day, class_name: SiriusApi::SemesterDay) do
  initialize_with do
    period = Fabricate(:teaching_semester_period)
    SiriusApi::SemesterDay.new(period, Date.parse('2014-10-01'), 2)
  end
end
