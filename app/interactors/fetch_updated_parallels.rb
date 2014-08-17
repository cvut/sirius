require 'update_log'
require 'interpipe/interactor'

class FetchUpdatedParallels
  include Interpipe::Interactor

  def setup(finder: Sirius::UpdatedParallelsFinder.new)
    @finder = finder
  end

  def perform(last_updated_since: nil, last_updated_till: nil)
    last_update_at = last_updated_since || get_last_updated_date
    @results = {kosapi_parallels: @finder.find_updated(last_update_at, last_updated_till) }
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
