require 'update_log'
require 'interpipe/interactor'

class FetchUpdatedParallels
  include Interpipe::Interactor

  def setup(finder: Sirius::UpdatedParallelsFinder.new)
    @finder = finder
  end

  def perform
    last_update_log = UpdateLog.last_partial_update
    if last_update_log
      last_update_at = last_update_log.created_at
    else
      last_update_at = Time.at(0) # start of unix epoch
    end
    @finder.find_updated(last_update_at)
  end

end
