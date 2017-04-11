# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

seeds_file = File.join(__dir__, 'seeds.sql')
if File.exists?(seeds_file)
  DB.run File.read(seeds_file)
end

if ENV['RACK_ENV'] == 'development'
  require 'models/token'
  faux_uuid = '11111111-1111-1111-8888-888888888888'
  Token.unrestrict_primary_key
  Token.find_or_create(uuid: faux_uuid) do |t|
    t.username = '*'
  end
end
