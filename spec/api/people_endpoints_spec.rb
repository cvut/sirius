require 'api_spec_helper'
require 'api/people_endpoints'

using Corefines::Enumerable::map_to

describe API::PeopleEndpoints do
  include_context 'API response'

  subject { body }

  describe 'GET /people/:username' do

    let!(:person) { Fabricate(:person) }
    let(:path) { "/people/#{person.id}" }

    it_behaves_like 'secured resource' do
      let(:username) { person.id }
    end

    context 'for authenticated user', authenticated: true do
      let(:access_token) { person.access_token }

      let(:json) do
        {
          id: person.id,
          full_name: person.full_name,
          access_token: person.access_token,
        }.to_json
      end

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

    context 'with read all scope' do
      context 'non-existing person', pending: 'cannot test limited OAuth scopes properly' do
        let(:path) { '/people/Fantomas' }
        it_behaves_like 'non-existent resource'
      end
    end
  end
end
