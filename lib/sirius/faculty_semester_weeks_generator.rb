module Sirius
  module FacultySemesterWeeksGenerator

    module_function

    def generate_semester_weeks_dates(semester)
      faculty_semester_weeks = SiriusApi::SemesterSchedule.resolve_weeks(semester.starts_at, semester.teaching_ends_at, semester.faculty)

      faculty_semester_weeks = faculty_semester_weeks.select { |week| week.teaching_week != nil }

      weeks_starts = faculty_semester_weeks.map { |week| week.start_date}
      weeks_ends = faculty_semester_weeks.map { |week| week.end_date}

      [weeks_starts, weeks_ends]
    end
  end
end
