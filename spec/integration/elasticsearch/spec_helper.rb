require 'spec_helper'
require 'rake'
require 'elasticsearch'
require 'elasticsearch/extensions/test/cluster/tasks'
require 'faraday/error'
require 'uri'

ELASTIC_ARGS = {
  network_host: URI(Config.elastic_url).host,
  port: URI(Config.elastic_url).port.to_s,
  nodes: 1,
  multicast_enabled: false
}
has_started_elastic = false

def elastic_running?
  begin
    Elasticsearch::Client.new(url: Config.elastic_url).ping
  rescue Faraday::Error::ClientError
    false
  end
end

RSpec.configure do |config|

  config.before(:context, :elasticsearch) do
    unless elastic_running?
      Elasticsearch::Extensions::Test::Cluster.start(ELASTIC_ARGS)
      has_started_elastic = true
    end
  end

  config.after(:context, :elasticsearch) do
    if has_started_elastic && elastic_running?
      Elasticsearch::Extensions::Test::Cluster.stop(ELASTIC_ARGS)
    end
  end
end
