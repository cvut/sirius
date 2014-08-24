require 'update_log'
require 'interpipe/interactor'
require 'sirius/updated_parallels_finder'

class FetchUpdatedParallels
  include Interpipe::Interactor

  def setup(finder: Sirius::UpdatedParallelsFinder.new)
    @finder = finder
  end

  def perform(last_updated_since: nil, last_updated_till: nil, faculty: nil, semester: nil, fetch_all: true)
    last_update_at = last_updated_since || get_last_updated_date
    updated_parallels = @finder.find_updated(last_update_at, last_updated_till, faculty: faculty, semester: semester)
    updated_parallels.auto_paginate = fetch_all
    @results = {kosapi_parallels: updated_parallels }
  end

  def get_last_updated_date
    last_update_log = UpdateLog.last_partial_update
    if last_update_log
      last_update_log.created_at
    else
      Time.at(0) # start of unix epoch
    end
  end

end
