class API < Grape::API

  version 'v1', using: :header, vendor: 'sirius'
  format :json

  mount Sirius::EventEndpoint
end
