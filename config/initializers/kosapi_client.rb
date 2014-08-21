require 'kosapi_client'

KOSapiClient.configure do |c|
  c.client_id = Config.kosapi_oauth_client_id
  c.client_secret = Config.kosapi_oauth_client_secret
end
