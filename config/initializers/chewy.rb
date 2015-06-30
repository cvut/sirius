require 'chewy'

Chewy.settings = {
  host: Config.elastic_url,
  prefix: Config.elastic_prefix
}
