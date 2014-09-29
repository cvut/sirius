# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'faculty_semester'

FacultySemester.create(code: 'B141', faculty: 18000, update_enabled: true, first_week_parity: :odd,
                        starts_at: '2014-09-22', teaching_ends_at: '2014-12-20', exams_start_at: '2015-01-05',
                        exams_end_at: '2015-02-14', ends_at: '2015-02-14',
                        hour_starts: %w(7:30 8:15 9:15 10:00 11:00 11:45 12:45 13:30 14:30 15:15 16:15 17:00 18:00 18:45 19:45), hour_duration: 45)
