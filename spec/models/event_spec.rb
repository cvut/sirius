require 'spec_helper'
require 'models/event'

describe Event do

  subject(:event) { Event.new(starts_at: Time.parse('11:00'), ends_at: Time.parse('12:30')) }
  let(:period) { Period.parse('7:30', '9:00') }

  it 'returns correct calculated period' do
    expect(event.period).to eq Period.parse('11:00', '12:30')
  end

  it 'sets starts_at and ends_at attributes from period=' do
    event.period = period
    expect(event.starts_at).to eq period.starts_at
    expect(event.ends_at).to eq period.ends_at
  end

  describe '.with_person' do
    let!(:event) { Fabricate(:event, teacher_ids: %w[marnytom], student_ids: %w[skocdpet vomackar]) }

    def with_person(person_id)
      described_class.with_person(person_id).all
    end

    it 'looks up both teachers and students' do
      expect(with_person 'marnytom').to eql [event]
      expect(with_person 'skocdpet').to eql [event]
    end

    it 'returns an empty set for unknown username' do
      expect(with_person 'novakj42').to be_empty
    end
  end

end
