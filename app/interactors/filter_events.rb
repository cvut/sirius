require 'role_playing'
require 'interpipe/interactor'
require 'core_ext/then'

require 'paginated_dataset'
require 'date_filtered_dataset'
##
# Filters events by page (offset, limit)
# depending on a requested format.
#
class FilterEvents
  include RolePlaying::Context
  include Interpipe::Interactor

  attr_reader :events

  def perform(events: , params: {}, format: :jsonapi)
    @events = DateFilteredDataset.played_by(events) do |dataset|
      dataset
        .filter_by_date(from: params[:from], to: params[:to])
        .then_if(paginate?(format)) do |d|
          PaginatedDataset.new(d).paginate(offset: params[:offset], limit: params[:limit])
        end
    end
  end

  private
  def paginate?(format)
    format != :ical
  end
end
