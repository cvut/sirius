require 'spec_helper'
require 'models/event'

describe Event do

  subject(:event) { Event.new(starts_at: Time.parse('11:00'), ends_at: Time.parse('12:30')) }
  let(:period) { Period.parse('7:30', '9:00') }

  describe '#period' do

    it 'returns correct calculated period' do
      expect(event.period).to eq Period.parse('11:00', '12:30')
    end

    it 'sets starts_at and ends_at attributes from period=' do
      event.period = period
      expect(event.starts_at).to eq period.starts_at
      expect(event.ends_at).to eq period.ends_at
    end

  end

  describe '.with_person' do
    let!(:event) { Fabricate(:event, teacher_ids: %w[marnytom], student_ids: %w[skocdpet vomackar]) }

    def with_person(person_id)
      described_class.with_person(person_id).all
    end

    it 'looks up both teachers and students' do
      expect(with_person 'marnytom').to contain_exactly event
      expect(with_person 'skocdpet').to contain_exactly event
    end

    it 'returns an empty set for unknown username' do
      expect(with_person 'novakj42').to be_empty
    end
  end

  describe '.with_teacher' do
    let!(:event) { Fabricate(:event, teacher_ids: %w[marnytom], student_ids: %w[skocdpet vomackar]) }

    def with_teacher(person_id)
      described_class.with_teacher(person_id).all
    end

    it 'looks up teachers only' do
      expect(with_teacher 'marnytom').to contain_exactly event
      expect(with_teacher 'skocdpet').to be_empty
    end

    it 'returns an empty set for unknown username' do
      expect(with_teacher 'novakj42').to be_empty
    end
  end

  describe '#sequence_number' do
    before { event.relative_sequence_number = 42 }
    it 'aliases relative_sequence_number' do
      expect(event.sequence_number).to eql 42
    end
  end

  describe '#move' do

    it 'moves start and end by an positive offset' do
      expect { event.move(5) }.to change(event, :period).from(Period.parse('11:00', '12:30')).to(Period.parse('11:05', '12:35'))
    end

    it 'moves start and end by an negative offset' do
      expect { event.move(-15) }.to change(event, :period).from(Period.parse('11:00', '12:30')).to(Period.parse('10:45', '12:15'))
    end

  end

end
