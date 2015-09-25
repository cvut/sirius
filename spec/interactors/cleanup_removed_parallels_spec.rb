require 'spec_helper'
require 'interactors/cleanup_removed_parallels'

describe CleanupRemovedParallels do

  let(:parallels) { Fabricate.times(2, :parallel) }
  let(:faculty_semester) { Fabricate.build(:faculty_semester, code: 'B132') }

  describe '#perform' do
    it 'sets deleted_at flag to missing parallels' do
      missing_parallel = parallels.delete_at(0)
      expect {
        described_class.perform(parallels: parallels, faculty_semester: faculty_semester)
        missing_parallel.refresh
      }.to change(missing_parallel, :deleted_at).from(nil)
    end

    it 'keeps present parallels intact' do
      missing_parallel = parallels.delete_at(0)
      expect {
        described_class.perform(parallels: parallels, faculty_semester: faculty_semester)
        missing_parallel.refresh
      }.not_to change(parallels.first, :deleted_at).from(nil)
    end

    it 'also marks related timetable slot as deleted' do
      missing_parallel = parallels.delete_at(0)
      slot = Fabricate(:timetable_slot, parallel_id: missing_parallel.id)
      expect {
        described_class.perform(parallels: parallels, faculty_semester: faculty_semester)
        slot.refresh
      }.to change(slot, :deleted_at).from(nil)
    end
  end

  describe '#results' do
    it 'passes other arguments unchaged' do
      instance = described_class.perform(parallels: [], faculty_semester: faculty_semester, foo: :bar)
      expect(instance.results).to include({foo: :bar})
    end
  end
end
