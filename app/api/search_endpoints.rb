require 'api_helper'
require 'corefines'
require 'search_results_representer'
require 'chewy/multi_search_index'

module API
  class SearchEndpoints < Grape::API

    using Corefines::Hash::only
    helpers ApiHelper

    before { authenticate! }

    resource :search do
      params do
        requires :q, type: String, desc: 'Search query'
        use :pagination
      end

      get do
        dataset = MultiSearchIndex.search(params.q)
            .limit(params.limit).offset(params.offset)

        SearchResultsRepresenter.for_collection
          .new(dataset)
          .to_hash('meta' => params.only(:limit, :offset).merge(count: dataset.total))
      end
    end
  end
end
