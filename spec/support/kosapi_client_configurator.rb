require 'kosapi_client'

module KOSapiClientConfigurator

  def create_kosapi_client
    KOSapiClient.new(client_id: ENV['OAUTH_CLIENT_ID'], client_secret: ENV['OAUTH_CLIENT_SECRET'])
  end
end
