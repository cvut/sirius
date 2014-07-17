require 'spec_helper'
require 'events_filtering'

describe EventsFiltering do
  let(:dataset) {  }
  let(:context) { descibed_class.new() }

  let(:events) do
    Fabricate.build_times(3, :event) do
      sequence(:starts_at, 1) { |i| "2014-04-0#{i} 14:30" }
      sequence(:ends_at, 1) { |i| "2014-04-0#{i} 16:00" }
    end
  end
  let(:context) { described_class.new(event) }

  let(:offset) { 1 }
  let(:limit) { 1 }

  context 'for JSON API format' do
    let(:format) { :jsonapi }

    it 'paginates stuff' do

    end
  end

  context 'for ICal format' do

  end
end
