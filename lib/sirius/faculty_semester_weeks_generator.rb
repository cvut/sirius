module Sirius
  module FacultySemesterWeeksGenerator

    module_function

    def generate_semester_weeks_dates(semester)
      faculty_semester_weeks = SiriusApi::SemesterWeek::resolve_weeks(semester, from: semester.starts_at, to: semester.teaching_ends_at).select(&:teaching_week)

      weeks_starts = faculty_semester_weeks.map { |week| week.start_date}
      weeks_ends = faculty_semester_weeks.map { |week| week.end_date}

      [weeks_starts, weeks_ends]
    end
  end
end
