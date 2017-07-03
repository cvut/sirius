require 'models/semester_period'

Fabricator(:semester_period) do
  id { sequence(:semester_period) }
  faculty_semester
  type 'teaching'
  irregular false
  first_week_parity 'odd'
  starts_at '2014-09-22'
  ends_at '2015-02-14'
end

Fabricator(:teaching_semester_period, from: :semester_period) do
  type 'teaching'
  first_week_parity 'odd'
  starts_at '2014-09-22'
  ends_at '2014-12-20'
end

Fabricator(:holiday_semester_period, from: :semester_period) do
  type 'holiday'
  name { {cs: 'Vánoční prázdniny', en: 'Christmas Holidays'} }
  first_week_parity nil
  starts_at '2014-12-21'
  ends_at '2015-01-04'
end

Fabricator(:exams_semester_period, from: :semester_period) do
  type 'exams'
  first_week_parity nil
  starts_at '2015-01-05'
  ends_at '2015-02-14'
end

Fabricator(:irregular_semester_period, from: :semester_period) do
  type 'teaching'
  irregular true
  first_day_override :wednesday
  starts_at '2014-12-22'
  ends_at '2014-12-22'
end
