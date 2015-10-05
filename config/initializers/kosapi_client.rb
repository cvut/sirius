require 'sirius/kosapi_client_registry'
require 'kosapi_client'

oauth_credentials = {
  client_id: Config.oauth_client_id,
  client_secret: Config.oauth_client_secret
}
fit_client = KOSapiClient.new(oauth_credentials)
fel_client = KOSapiClient.new(oauth_credentials.merge({base_url: 'https://kosapi.feld.cvut.cz/api/3'}))

registry = Sirius::KOSapiClientRegistry.instance
registry.register_client(fit_client, 18_000, default: true)
registry.register_client(fel_client, 13_000)
