class API < Grape::API

  version 'v1', using: :header, vendor: 'sirius'
  format :json


  rescue_from Grape::Exceptions::ValidationErrors do |e|
    status = 422 # e.status is 400 -- hardcoded by Grape
    Rack::Response.new({
      status: status,
      message: e.message,
      errors: e.errors
    }.to_json, status)
  end


  mount Sirius::EventResource
end
