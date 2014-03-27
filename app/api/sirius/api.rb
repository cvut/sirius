module Sirius
  class API < Grape::API

    version 'v1', using: :header, vendor: 'sirius'
    format :json

    resource :events do

      desc 'Test resource'
      get do
        'Hello world'
      end
    end
  end
end
