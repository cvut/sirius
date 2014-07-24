module Sirius
  class PartialParallelImport

    def initialize(limit: nil, semester: nil, finder: UpdatedParallelsFinder.new)
      @limit = limit
      @semester = semester
      @finder = finder
    end

    def run
      fetch_parallels
      process_records
      save_records
    end

    def fetch_parallels
      last_update_log = UpdateLog.last_partial_update
      if last_update_log
        last_update_at = last_update_log.created_at
      else
        last_update_at = Time.at(0) # start of unix epoch
      end
      @parallels = @finder.find_updated(last_update_at)
    end

    def process_records

    end

    def save_records

    end

  end
end
