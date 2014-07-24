require 'kosapi_client'

module KOSapiClientConfigurator

  def create_kosapi_client
    KOSapiClient.new(client_id: ENV['KOSAPI_OAUTH_CLIENT_ID'], client_secret: ENV['KOSAPI_OAUTH_CLIENT_SECRET'])
  end


end
