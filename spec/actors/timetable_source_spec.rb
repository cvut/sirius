require 'spec_helper'
require 'actors/timetable_source'

describe TimetableSource, :vcr do
  include ActorHelper

  let(:semester) { Fabricate(:faculty_semester, code: 'B151') }
  subject(:source) { described_class.new(nil, nil, semester).bare_object }
  let(:teacher_username) { 'szolatib' }

  describe '#generate_row' do
    it 'raises StopIteration error with no data' do
      expect { source.generate_row }.to raise_error(StopIteration)
    end

    it 'outputs single teacher timetable slot together with username' do
      source.process_row(teacher_username)
      timetable_slot, username = source.generate_row
      expect(username).to eq teacher_username
      expect(timetable_slot).to have_attributes(
        day: 1,
        duration: 2,
        first_hour: 1,
        parity: :both
      )
    end

  end
end
