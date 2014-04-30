# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

scala = Course.create(code: 'MI-PSL', department: '18102', name: Sequel.hstore({cs:'Programování v jazyku Scala', en: 'Programming in Scala'}))

room = Room.create({code: 'T9:350'})

Event.create({name:'MI-PSL 1. cvičení', starts_at: DateTime.strptime('03/05/2014 9:15', '%m/%d/%Y %H:%M'), ends_at: DateTime.strptime('03/05/2014 10:45', '%m/%d/%Y %H:%M'), sequence_number: 1})
Event.create({name:'MI-PSL 2. cvičení', starts_at: DateTime.strptime('03/12/2014 9:15', '%m/%d/%Y %H:%M'), ends_at: DateTime.strptime('03/12/2014 10:45', '%m/%d/%Y %H:%M'), sequence_number: 2})
Event.create({name:'MI-PSL 3. cvičení', starts_at: DateTime.strptime('03/19/2014 9:15', '%m/%d/%Y %H:%M'), ends_at: DateTime.strptime('03/19/2014 10:45', '%m/%d/%Y %H:%M'), sequence_number: 3})

scala_101 = Parallel.create({code: 101, capacity: 24, occupied: 24, semester: 'B132', course_id: scala.id})
scala_102 = Parallel.create({code: 101, capacity: 24, occupied: 24, semester: 'B132', course_id: scala.id})

TimetableSlot.create({day: 1, parity: 0, first_hour: 1, duration: 2, room_id: room.id, parallel_id: scala_101.id})
TimetableSlot.create({day: 3, parity: 1, first_hour: 6, duration: 2, room_id: room.id, parallel_id: scala_102.id})

