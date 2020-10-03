require 'spec_helper'
require 'interactors/convert_rooms'

describe ConvertRooms do

  describe '#perform' do

    subject(:convert) { described_class }
    let(:room) { double(:room, link_id: 'MK:209', link_title: 'MK:209') }
    let(:room_nil) { double(:room, link_id: 'MK:209', link_title: 'no-title') }
    let(:rooms) { [room] }

    it 'returns empty array when nil rooms only' do
      results = convert.perform(kosapi_rooms: [room_nil]).results
      expect(results[:rooms]).to be_empty
    end

    it 'returns empty array when no slots' do
      results = convert.perform(kosapi_rooms: []).results
      expect(results[:rooms]).to be_empty
    end

    it 'converts timetable slot rooms' do
      results = convert.perform(kosapi_rooms: rooms).results
      room = results[:rooms].first
      expect(room.kos_code).to eq 'MK:209'
    end

    it 'converts only non-nil timetable slot rooms' do
      results = convert.perform(kosapi_rooms: [room, room_nil]).results
      expect(results[:rooms].map(&:kos_code)).to eq ['MK:209']
    end

    it 'passes timetable_slots through' do
      results = convert.perform({timetable_slots: {}, kosapi_rooms: [], foo: :bar}).results
      expect(results).to include :timetable_slots
    end

    it 'passes other data through' do
      results = convert.perform({timetable_slots: {}, kosapi_rooms: [], foo: :bar}).results
      expect(results).to include foo: :bar
    end

  end

end
