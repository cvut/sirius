require 'kosapi_client'

module Sirius
  class UpdatedParallelsFinder

    def initialize(client: KOSapiClient.client)
      @client = client
    end

    def find_updated(since, till = nil, page_size: 100)
      query = build_query(since, till)
      @client.parallels.where(query).limit(page_size)
    end

    private
    def build_query(since, till)
      since_str = format_time_kosapi(since)
      if till
        till_str = format_time_kosapi(till)
        "(lastUpdatedDate>=#{since_str};lastUpdatedDate<=#{till_str}),(timetableSlot/lastUpdatedDate>=#{since_str};timetableSlot/lastUpdatedDate<=#{till_str})"
      else
        "lastUpdatedDate>=#{since_str},timetableSlot/lastUpdatedDate>=#{since_str}"
      end
    end

    def format_time_kosapi(time)
      time.strftime('%Y-%m-%dT%H:%M:%S')
    end

  end
end
