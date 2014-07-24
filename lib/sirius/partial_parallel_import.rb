module Sirius
  class PartialParallelImport

    def initialize(limit: , semester: , client: KOSapiClient.client, finder: UpdatedParallelsFinder.new)
      @limit = limit
      @semester = semester
      @client = client
      @finder = finder
    end

    def run
      fetch_parallels
      process_records
      save_records
    end

    def fetch_parallels
      @parallels = finder.find_updated
    end

    def process_records

    end

    def save_records

    end

  end
end
