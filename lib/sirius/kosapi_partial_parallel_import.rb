module Sirius
  class KOSapiPartialParallelImport

    def initialize(limit: , semester: , client: KOSapiClient.client, finder: UpdatedParallelsFinder)
      @limit = limit
      @semester = semester
      @client = client
      @finder = finder.new()
    end

    def run
      fetch_parallels
      process_records
      save_records
    end

    def fetch_parallels

    end

    def process_records

    end

    def save_records

    end

  end
end
