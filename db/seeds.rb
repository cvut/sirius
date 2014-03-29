# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Course.create({code: 'MI-PSL', department: '18102', name: Sequel.hstore({cs:'Programování v jazyku Scala', en: 'Programming in Scala'})})

Event.create({name:'MI-PSL 1. cvičení', starts_at: DateTime.strptime('03/05/2014 9:15', '%m/%d/%Y %H:%M'), ends_at: DateTime.strptime('03/05/2014 10:45', '%m/%d/%Y %H:%M'), sequence_number: 1})
Event.create({name:'MI-PSL 2. cvičení', starts_at: DateTime.strptime('03/12/2014 9:15', '%m/%d/%Y %H:%M'), ends_at: DateTime.strptime('03/12/2014 10:45', '%m/%d/%Y %H:%M'), sequence_number: 2})
Event.create({name:'MI-PSL 3. cvičení', starts_at: DateTime.strptime('03/19/2014 9:15', '%m/%d/%Y %H:%M'), ends_at: DateTime.strptime('03/19/2014 10:45', '%m/%d/%Y %H:%M'), sequence_number: 3})

