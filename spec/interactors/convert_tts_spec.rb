require 'spec_helper'
require 'interactors/convert_tts'

describe ConvertTTS do

  describe '#perform' do

    context 'with no slots' do

      it 'returns empty result' do
        slots = {}
        results = described_class.perform(timetable_slots: slots, rooms: []).results
        expect(results).to eq({timetable_slots: []})
      end

    end

    context 'with slots' do

      let(:slot) do
        slot = {
          id: 239019,
          day: 5,
          duration: 2,
          parity: 'both',
          first_hour: 3,
          room: double(link_id: 'MK:209'),
          start_time: Time.parse('14:30:00'),
          end_time: Time.parse('16:00:00'),
          weeks: nil,
        }
        double(**slot, to_hash: slot)
      end
      let(:room) { Fabricate(:room, id: 'MK:209') }
      let(:slots) { {'1234' => [slot]} }

      it 'converts timetable slots' do
        results = described_class.perform(timetable_slots: slots, rooms: []).results
        converted_slot = results[:timetable_slots].first
        expect(converted_slot.id).to eq 239019
        expect(converted_slot.day).to eq :friday
        expect(converted_slot.duration).to eq 2
        expect(converted_slot.parity).to eq 'both'
        expect(converted_slot.first_hour).to eq 3
        expect(converted_slot.start_time).to eq Time.parse('14:30:00')
        expect(converted_slot.end_time).to eq Time.parse('16:00:00')
      end

      it 'loads rooms' do
        results = described_class.perform(timetable_slots: slots, rooms: [room]).results
        converted_slot = results[:timetable_slots].first
        expect(converted_slot.room.kos_code).to eq 'MK:209'
      end

      it 'sets parallel id' do
        results = described_class.perform(timetable_slots: slots, rooms: [room]).results
        converted_slot = results[:timetable_slots].first
        expect(converted_slot.parallel_id).to eq 1234
      end

      context 'slot with weeks' do
        let(:slot_with_weeks) do
          hash = { **slot.to_hash, weeks: '1-3,5' }
          double(**hash, to_hash: hash)
        end
        let(:slots) { {'1234' => [slot_with_weeks]} }

        it 'converts weeks and sets parity to nil' do
          results = described_class.perform(timetable_slots: slots, rooms: []).results
          converted_slot = results[:timetable_slots].first

          expect(converted_slot.parity).to be_nil
          expect(converted_slot.weeks).to eq([1, 2, 3, 5])
        end
      end
    end

    context 'with invalid slots' do

      let(:slot) do
        slot = {
          id: 239019,
          day: nil,  # <-- missing day
          duration: 2,
          parity: 'both',
          first_hour: 3,
          room: double(link_id: 'MK:209'),
          start_time: nil,
          end_time: nil,
          weeks: nil,
        }
        double(**slot, to_hash: slot)
      end
      let(:slots) { {'1234' => [slot]} }

      it 'rejects them' do
        results = described_class.perform(timetable_slots: slots, rooms: []).results
        expect(results[:timetable_slots]).to be_empty
      end

    end

  end

end
