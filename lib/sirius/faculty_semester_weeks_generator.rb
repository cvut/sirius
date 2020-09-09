require 'sirius_api/semester_week'

module Sirius
  module FacultySemesterWeeksGenerator

    module_function

    def generate_semester_weeks_dates(semester)
      SiriusApi::SemesterWeek
        .resolve_weeks(semester, from: semester.starts_at, to: semester.teaching_ends_at)
        .select(&:teaching_week)
        .map { |week| [week.start_date, week.end_date]}
    end
  end
end
