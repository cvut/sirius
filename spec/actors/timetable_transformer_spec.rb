require 'spec_helper'
require 'actors/timetable_transformer'
require 'roles/planned_semester_period'

describe TimetableTransformer do

  let!(:semester) { Fabricate(:faculty_semester) }

  # One whole week plus following Monday and Tuesday
  let!(:period1) {
    Fabricate(:semester_period,
      faculty_semester: semester,
      starts_at: '2015-10-19',
      ends_at: '2015-10-27'
    )
  }

  # Holiday on Wednesday
  let!(:period2) {
    Fabricate(:holiday_semester_period,
      faculty_semester: semester,
      starts_at: '2015-10-28',
      ends_at: '2015-10-28'
    )
  }

  # Rest of the week after holiday and a whole week after that.
  let!(:period3) {
    Fabricate(:exams_semester_period,
      faculty_semester: semester,
      starts_at: '2015-10-29',
      ends_at: '2015-11-08'
    )
  }

  let(:slot) {
    double(:slot, id: 42, day: 1, duration: 2,
      first_hour: 1, parity: :both, title: 'Meditation'
    )
  }

  let(:teacher) { 'vomackar' }

  let(:transformer_actor) { described_class.new(nil, semester) }

  # Using #bare_object to bypass Celluloid actor proxy
  subject(:transformer) { transformer_actor.bare_object }

  describe '#plan_events' do
    it 'plans semester periods' do
      events = transformer.plan_events(slot, teacher)
      expect(events.count).to be 3
    end

    it 'numbers events sequentially starting from one' do
      events = transformer.plan_events(slot, teacher)
      expect(events.map(&:absolute_sequence_number)).to eq (1..events.count).to_a
    end
  end
end
