require 'sirius_api/semester_week'
require 'date_refinements'

using DateRefinements

Fabricator(:semester_week, class_name: SiriusApi::SemesterWeek) do
  initialize_with do
    period = Fabricate(:teaching_semester_period)
    SiriusApi::SemesterWeek.new(period.faculty_semester, [period],
        period.starts_at.start_of_week, 1)
  end
end

Fabricator(:semester_week_2, class_name: SiriusApi::SemesterWeek) do
  initialize_with do
    period = Fabricate(:teaching_semester_period)
    SiriusApi::SemesterWeek.new(period.faculty_semester, [period],
        period.starts_at.start_of_week + 7, 2)
  end
end
