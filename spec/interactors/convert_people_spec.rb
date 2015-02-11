require 'spec_helper'
require 'interactors/convert_people'

describe ConvertPeople do

  let(:people) { [double(link_id: 'kordikp', link_title: 'Ing. Pavel Kordík Ph.D.')] }

  it 'converts people' do
    subject.perform(kosapi_people: people)
    people = subject.results[:people]
    person = people.first
    expect(person.full_name).to eq 'Ing. Pavel Kordík Ph.D.'
    expect(person.id).to eq 'kordikp'
  end


end
