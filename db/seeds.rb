# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'models/faculty_semester'
require 'models/semester_period'

std_hour_starts = Sequel.pg_array(%w(7:30 8:15 9:15 10:00 11:00 11:45 12:45 13:30 14:30 15:15 16:15 17:00 18:00 18:45 19:45),
                  :time)

FacultySemester.find_or_create(code: 'B141', faculty: 18000) do |s|
  s.update_parallels = false
  s.first_week_parity = :odd
  s.starts_at = '2014-09-22'
  s.teaching_ends_at = '2014-12-20'
  s.exams_start_at = '2015-01-05'
  s.exams_end_at = '2015-02-14'
  s.ends_at = '2015-02-14'
  s.hour_starts = std_hour_starts
  s.hour_duration = 45
end

FacultySemester.find_or_create(code: 'B141', faculty: 13000) do |s|
  s.update_parallels = false
  s.first_week_parity = :odd
  s.starts_at = '2014-09-22'
  s.teaching_ends_at = '2014-12-20'
  s.exams_start_at = '2015-01-05'
  s.exams_end_at = '2015-02-14'
  s.ends_at = '2015-02-14'
  s.hour_starts = std_hour_starts
  s.hour_duration = 45
end

fitb142 = FacultySemester.find_or_create(code: 'B142', faculty: 18000) do |s|
  s.update_parallels = false
  s.update_other = true
  s.first_week_parity = :even
  s.starts_at = '2015-02-16'
  s.teaching_ends_at = '2015-05-16'
  s.exams_start_at = '2015-05-18'
  s.exams_end_at = '2015-06-27'
  s.ends_at = '2015-09-21'
  s.hour_starts = std_hour_starts
  s.hour_duration = 45
end

fitb151 = FacultySemester.find_or_create(code: 'B151', faculty: 18000) do |s|
  s.update_parallels = true
  s.update_other = true
  s.first_week_parity = :odd
  s.starts_at = '2015-10-05' # FIXME: actual start is on 01
  s.teaching_ends_at = '2016-01-10'
  s.exams_start_at = '2016-01-11'
  s.exams_end_at = '2016-02-20'
  s.ends_at = '2016-02-21'
  s.hour_starts = std_hour_starts
  s.hour_duration = 45
end

felb151 = FacultySemester.find_or_create(code: 'B151', faculty: 13000) do |s|
  s.update_parallels = true
  s.update_other = true
  s.first_week_parity = :even
  s.starts_at = '2015-10-01'
  s.teaching_ends_at = '2016-01-17'
  s.exams_start_at = '2016-01-18'
  s.exams_end_at = '2016-02-21'
  s.ends_at = '2016-02-21'
  s.hour_starts = std_hour_starts
  s.hour_duration = 45
end

periods = [
  {
    type: :teaching,
    starts_at: '2015-02-16',
    ends_at: '2015-05-15',
    first_week_parity: :even,
    faculty_semester: fitb142,
  },
  {
    type: :exams,
    starts_at: '2015-05-18',
    ends_at: '2015-06-26',
    faculty_semester: fitb142,
  },
  {
    type: :holiday,
    starts_at: '2015-06-29',
    ends_at: '2015-08-28',
    faculty_semester: fitb142,
  },
  ### B151
  ## FIT
  {
    type: :teaching,
    starts_at: '2015-10-05',
    ends_at: '2015-12-22',
    first_week_parity: :odd,
    faculty_semester: fitb151,
  },
  {
    type: :holiday,
    starts_at: '2015-12-23',
    ends_at: '2016-01-03',
    faculty_semester: fitb151,
  },
  {
    type: :teaching,
    starts_at: '2016-01-04',
    ends_at: '2016-01-10',
    first_week_parity: :even,
    faculty_semester: fitb151,
  },
  {
    type: :exams,
    starts_at: '2016-01-11',
    ends_at: '2016-02-20',
    faculty_semester: fitb151,
  },
  ## FEL
  {
    type: :teaching,
    starts_at: '2015-10-01',
    ends_at: '2015-12-22',
    first_week_parity: :odd,
    faculty_semester: felb151,
  },
  {
    type: :holiday,
    starts_at: '2015-12-23',
    ends_at: '2016-01-03',
    faculty_semester: felb151,
  },
  {
    type: :teaching,
    starts_at: '2016-01-04',
    ends_at: '2016-01-17',
    first_week_parity: :even,
    faculty_semester: felb151,
  },
  {
    type: :exams,
    starts_at: '2016-01-18',
    ends_at: '2016-02-21',
    faculty_semester: felb151,
  },
]

periods.each do |period|
  fsid = period[:faculty_semester].id
  SemesterPeriod.find_or_create(faculty_semester_id: fsid, starts_at: period[:starts_at]) do |sp|
    sp.type = period[:type]
    sp.ends_at = period[:ends_at]
    sp.first_week_parity = period[:first_week_parity]
  end
end


if ENV['RACK_ENV'] == 'development'
  require 'token'
  faux_uuid = '11111111-1111-1111-8888-888888888888'
  Token.unrestrict_primary_key
  Token.find_or_create(uuid: faux_uuid) do |t|
    t.username = '*'
  end
end
