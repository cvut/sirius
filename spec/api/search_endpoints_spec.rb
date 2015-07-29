require 'api_spec_helper'
require 'corefines'
require 'ostruct'

using Corefines::Enumerable::map_to

describe API::SearchEndpoints do
  include_context 'API response'

  subject { body }

  describe 'GET /search' do

    let(:path) { '/search?q=foo' }
    let(:json_type) { 'results' }

    it_behaves_like 'secured resource'

    context 'for authenticated user', authenticated: true do

      context "without 'q' parameter" do

        let(:path) { '/search' }

        before { auth_get path_for(path) }

        it 'returns 400' do
          expect( status ).to eq 400
        end
      end

      context "with 'q' parameter" do

        let(:path) { '/search?q=rub' }

        let(:results) do
          [
            { id: 'MI-RUB', title: 'Ruby', type: 'course' },
            { id: 'rubyelis', title: 'Elisia Ruby', type: 'person' },
            { id: 'rubierno', title: 'Erno Rubik', type: 'person' }
          ]
        end
        let(:total_count) { 15 }

        before do
          allow(MultiSearchIndex).to receive(:search) do |q, kwargs|
            limit = kwargs.fetch(:limit, 10)
            PageMeta.new(results[0...limit].map_to(OpenStruct), count: total_count, **kwargs)
          end
        end

        it_behaves_like 'paginated resource'

        specify do
          auth_get path_for(path)
          should be_json_eql(results.to_json).at_path('results')
        end
      end
    end
  end
end
