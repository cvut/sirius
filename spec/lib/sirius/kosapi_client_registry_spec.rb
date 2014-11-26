require 'spec_helper'
require 'sirius/kosapi_client_registry'

describe Sirius::KOSapiClientRegistry do

  subject(:registry) { described_class.new }

  let(:client) { double(:client) }
  let(:faculty) { 18000 }

  describe '#register_client' do

    it 'stores client into registry' do
      subject.register_client(client, faculty)
      expect(subject.client_for_faculty(faculty)).to be client
    end

    it 'does not set client as default when default: false' do
      subject.register_client(client, faculty, default: false)
      expect(subject.client_for_faculty(42)).to be nil
    end


    it 'sets client as default when default: true' do
      subject.register_client(client, faculty, default: true)
      expect(subject.client_for_faculty(42)).to be client
    end
  end

  describe '#client_for_faculty' do

    it 'returns nil when no clients registered' do
      expect(subject.client_for_faculty(42)).to be nil
    end

  end

  describe '.instance' do

    it 'creates and returns new instance' do
      expect(described_class.instance).to be_an_instance_of described_class
    end

    it 'keeps created instance' do
      expect(described_class.instance).to be described_class.instance
    end

  end

end
