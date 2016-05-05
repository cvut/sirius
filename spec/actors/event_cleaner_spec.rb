require 'spec_helper'
require 'actors/events_cleaner'

describe EventsCleaner do
  include ActorHelper

  let(:semester) { Fabricate(:faculty_semester, code: 'B151') }
  subject(:actor) { described_class.new(nil, nil, semester, 'lecture').bare_object }

  describe '#mark_unseen_events!' do
    let!(:event) { Fabricate(:event, faculty: semester.faculty, semester: semester.code) }

    it 'marks unseen events with specified type as deleted' do
      expect {
        actor.mark_unseen_events!(semester, [], 'lecture')
        event.refresh
      }.to change(event, :deleted).from(false).to(true)
    end

    it 'does not mark seen events' do
      expect {
        actor.mark_unseen_events!(semester, [event.id], 'lecture')
        event.refresh
      }.not_to change(event, :deleted).from(false)
    end

    it 'does not mark unseen events with different type' do
      expect {
        actor.mark_unseen_events!(semester, [], 'exam')
        event.refresh
      }.not_to change(event, :deleted).from(false)
    end

    it 'does not mark unseen events with different semester' do
      event.semester = 'B162'
      event.save
      expect {
        actor.mark_unseen_events!(semester, [], 'lecture')
        event.refresh
      }.not_to change(event, :deleted).from(false)
    end
  end

  describe '#process_row' do
    let(:events) { [double(id: 1)] }

    it 'sends hungry notification' do
      expect(actor).to receive(:notify_hungry)
      actor.process_row(events)
    end
  end
end
