require 'kosapi_client'

module Sirius
  class UpdatedParallelsFinder

    def initialize(since: )
      @since = since
      @client = KOSapiClient.client
    end

    def find_updated
      time_str = format_time_kosapi(@since)
      @client.parallels.where("lastUpdatedDate>=#{time_str}")
    end

    private
    def format_time_kosapi(time)
      time.strftime('%Y-%m-%dT%H:%M:%S')
    end

  end
end
