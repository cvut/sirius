# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'faculty_semester'

FacultySemester.find_or_create(code: 'B141', faculty: 18000) do |s|
  s.update_enabled = true
  s.first_week_parity = :odd
  s.starts_at = '2014-09-22'
  s.teaching_ends_at = '2014-12-20'
  s.exams_start_at = '2015-01-05'
  s.exams_end_at = '2015-02-14'
  s.ends_at = '2015-02-14'
  s.hour_starts = %w(7:30 8:15 9:15 10:00 11:00 11:45 12:45 13:30 14:30 15:15 16:15 17:00 18:00 18:45 19:45)
  s.hour_duration = 45
end

FacultySemester.find_or_create(code: 'B141', faculty: 13000) do |s|
  s.update_enabled = false
  s.first_week_parity = :odd
  s.starts_at = '2014-09-22'
  s.teaching_ends_at = '2014-12-20'
  s.exams_start_at = '2015-01-05'
  s.exams_end_at = '2015-02-14'
  s.ends_at = '2015-02-14'
  s.hour_starts = %w(7:30 8:15 9:15 10:00 11:00 11:45 12:45 13:30 14:30 15:15 16:15 17:00 18:00 18:45 19:45)
  s.hour_duration = 45
end

if ENV['RACK_ENV'] == 'development'
  require 'token'
  faux_uuid = '11111111-1111-1111-8888-888888888888'
  Token.unrestrict_primary_key
  Token.find_or_create(uuid: faux_uuid) do |t|
    t.username = '*'
  end
end
