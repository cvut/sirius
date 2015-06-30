require 'api_helper'
require 'global_search_helper'
require 'search_results_representer'

module API
  class SearchEndpoints < Grape::API
    helpers ApiHelper

    resource :search do
      params do
        requires :q, type: String, desc: 'Search query'
        use :pagination
      end

      get do
        represent_paginated(GlobalSearchHelper.search(params.q), SearchResultsRepresenter)
      end
    end
  end
end
