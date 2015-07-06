require 'api_helper'
require 'corefines'
require 'search_results_representer'
require 'models/multi_search_index'

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
        results = MultiSearchIndex.search(params.q, **params_h.only(:limit, :offset))
        SearchResultsRepresenter.for_collection
          .new(results).to_hash('meta' => results.page_meta)
      end
    end
  end
end
