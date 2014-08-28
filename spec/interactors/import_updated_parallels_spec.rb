require 'spec_helper'
require 'interactors/import_updated_parallels'

describe ImportUpdatedParallels, :integration, :vcr do

  before { allow(KOSapiClient).to receive(:client).and_return(create_kosapi_client) }

  describe '#perform' do

    let(:since) { Time.parse('1.7.2014') }
    let(:till) { Time.parse('10.7.2014') }

    it 'imports parallels' do
      expect do
        subject.perform(last_updated_since: since, last_updated_till: till, faculty: 18000)
      end.to change(Parallel, :count).from(0)
    end

  end


end
