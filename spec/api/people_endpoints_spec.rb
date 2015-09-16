require 'api_spec_helper'
require 'api/people_endpoints'

using Corefines::Enumerable::map_to

describe API::PeopleEndpoints do
  include_context 'API response'

  subject { body }

  describe 'GET /people/:username' do
    let(:username) { 'user' }
    let!(:entity) { Fabricate(:person, id: username) }
    let(:path) { "/people/#{username}" }

    let(:json) do
      {
        id: entity.id,
        full_name: entity.full_name,
        access_token: entity.access_token,
      }.to_json
    end

    it_behaves_like 'secured resource' do
      let(:username) { 'user' }
    end

    context 'for authenticated user', authenticated: true do
      context 'with personal personal read scope' do
        context 'for authorized person accessing personal data' do

          before { auth_get path_for(path) }

          it 'returns OK' do
            expect(status).to eql 200
          end

          it { should be_json_eql(json).at_path('people') }
        end

        context 'for authorized person accessing data for someone else' do
          let(:path) { '/people/anotheruser' }
          it_behaves_like 'forbidden resource'
        end
      end
    end

    pending 'no idea how to mock this' do
      context 'with read all scope' do
        context 'non-existing person' do
          let(:path) { '/people/Fantomas' }
          it_behaves_like 'non-existent resource'
        end
      end
    end
  end
end
