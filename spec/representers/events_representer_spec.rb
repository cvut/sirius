require 'spec_helper'
require 'events_representer'
require 'json_spec'

describe EventsRepresenter do
  include JsonSpec::Helpers

  # let(:room) { Fabricate(:room, kos_code: 'T9:350') }
  let(:size) { 3 }
  let(:collection) { Fabricate.build_times(size, :event) }
  let(:options) { Hash.new }

  subject(:representer) { described_class.new(collection, options) }

  describe '#to_ical' do
    it { should respond_to(:to_ical) }

    it 'returns a string' do
      expect(representer.to_ical).to be_a String
    end
  end

  describe 'JSON serialization' do
    let(:size) { 40 }
    let(:meta) do
      {
        count: 40,
        offset: 0,
        limit: 20
      }
    end
    let(:options) { meta }
    subject(:json) { representer.to_json }

    it { should have_json_size(3).at_path('events') }

    it { should be_json_eql(meta.to_json).at_path('meta') }
  end

end
