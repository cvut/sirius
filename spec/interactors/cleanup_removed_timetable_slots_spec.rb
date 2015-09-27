require 'spec_helper'
require 'interactors/cleanup_removed_timetable_slots'

describe CleanupRemovedTimetableSlots do

  let(:slots) { Fabricate.times(2, :timetable_slot) }
  let(:faculty_semester) { Fabricate.build(:faculty_semester, code: 'B132') }

  describe '#perform' do
    it 'sets deleted_at flag to missing timetable_slots' do
      missing_slot = slots.delete_at(0)
      expect {
        described_class.perform(timetable_slots: slots, faculty_semester: faculty_semester)
        missing_slot.refresh
      }.to change(missing_slot, :deleted_at).from(nil)
    end

    it 'keeps present slots intact' do
      missing_slot = slots.delete_at(0)
      expect {
        described_class.perform(timetable_slots: slots, faculty_semester: faculty_semester)
        missing_slot.refresh
      }.not_to change(slots.first, :deleted_at).from(nil)
    end
  end

  describe '#results' do
    it 'passes other arguments unchaged' do
      instance = described_class.perform(timetable_slots: [], faculty_semester: faculty_semester, foo: :bar)
      expect(instance.results).to include({foo: :bar})
    end
  end
end
