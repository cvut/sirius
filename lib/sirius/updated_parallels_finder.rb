require 'kosapi_client'

module Sirius
  class UpdatedParallelsFinder

    def initialize(client: KOSapiClient.client)
      @client = client
    end

    def find_updated(since, till = nil, page_size: 100, faculty: nil, semester: nil)
      query = build_query(since, till, faculty, semester)
      @client.parallels.where(query).limit(page_size)
    end

    private
    def build_query(since, till, faculty, semester)
      since_str = format_time_kosapi(since)
      if till
        till_str = format_time_kosapi(till)
        query = "((lastUpdatedDate>=#{since_str};lastUpdatedDate<=#{till_str}),(timetableSlot/lastUpdatedDate>=#{since_str};timetableSlot/lastUpdatedDate<=#{till_str}))"
      else
        query = "(lastUpdatedDate>=#{since_str},timetableSlot/lastUpdatedDate>=#{since_str})"
      end
      query += ";(course.faculty=#{faculty})" if faculty
      query += ";(semester=#{semester})" if semester
      query
    end

    def format_time_kosapi(time)
      time.strftime('%Y-%m-%dT%H:%M:%S')
    end

  end
end
