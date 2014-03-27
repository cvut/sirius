# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Course.create({code: 'MI-PSL', department: '18102', name: Sequel.hstore({cs:'Programování v jazyku Scala', en: 'Programming in Scala'})})

