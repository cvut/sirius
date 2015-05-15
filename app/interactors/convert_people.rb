require 'interpipe/interactor'
require 'person'

class ConvertPeople
  include Interpipe::Interactor

  def perform(kosapi_people:, **opts)
   @people = kosapi_people.map { |person| convert_person(person) }
  end

  def results
    { people: @people }
  end

  def convert_person(person_link)
    username = person_link.link_id
    Person.new(full_name: person_link.link_title) { |p| p.id = username }
  end

end
