module Sirius
  module FacultySemesterWeeksGenerator

    module_function

    def generate_semester_weeks_dates(semester)
      faculty_semester_weeks = SiriusApi::SemesterWeek::resolve_weeks(semester, from: semester.starts_at, to: semester.teaching_ends_at).select(&:teaching_week)
      faculty_semester_weeks.map { |week| [week.start_date, week.end_date]}
    end
  end
end
