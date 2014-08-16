require 'spec_helper'
require 'interactors/convert_rooms'

describe ConvertRooms do

  describe '#perform' do

    subject(:convert) { described_class }
    let(:slot) { double(room: double(link_title: 'MK:209')) }

    it 'returns empty array when no slots' do
      results = convert.perform({timetable_slots: {}}).results
      expect(results[:rooms]).to eq []
    end

    it 'converts timetable slot rooms' do
      results = convert.perform({timetable_slots: {'1234' => [slot]}}).results
      room = results[:rooms].first
      expect(room.kos_code).to eq 'MK:209'
    end

    it 'passes through other data' do
      results = convert.perform({timetable_slots: {}, foo: :bar}).results
      expect(results).to include foo: :bar
    end

  end

end
