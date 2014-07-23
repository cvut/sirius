require 'spec_helper'
require 'sirius/room_cache'

describe Sirius::RoomCache do

  subject(:room_cache) { Sirius::RoomCache.new }

  it 'creates new room if not present' do
    room = room_cache.find_or_create_by_kos_code('TH:A-1242')
    expect(room.id).not_to be_nil
    expect(room.kos_code).to eq 'TH:A-1242'
  end

  it 'loads existing Room from database' do
    Fabricate(:room, kos_code: 'TH:A-1242')
    room = room_cache.find_or_create_by_kos_code('TH:A-1242')
    expect(room.id).not_to be_nil
    expect(room.kos_code).to eq 'TH:A-1242'
  end

  it 'keeps loaded data in cache' do
    room1 = room_cache.find_or_create_by_kos_code('TH:A-1242')
    room2 = room_cache.find_or_create_by_kos_code('TH:A-1242')
    expect(room1).to be room2
  end

end
