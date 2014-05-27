require 'kosapi_client'

KOSapiClient.configure do |c|
  c.client_id = ENV['KOSAPI_OAUTH_CLIENT_ID']
  c.client_secret = ENV['KOSAPI_OAUTH_CLIENT_SECRET']
end
