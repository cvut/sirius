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

  attr_reader :events, :limit, :offset

  DEFAULT_LIMIT = 20

  def perform(events: , params: {}, format: :jsonapi)
    @events = DateFilteredDataset.played_by(events) do |dataset|
      dataset
        .filter_by_date(from: params[:from], to: params[:to])
        .tap {|d|
          @count = nil
          @count_query = d
        }
        .then_if(paginate?(format)) { |d|
          @offset = params[:offset] || 0
          @limit = params[:limit] || DEFAULT_LIMIT
          PaginatedDataset.new(d).paginate(offset: @offset, limit: @limit)
        }
    end
  end

  def count
    @count ||= @count_query.count
  end

  def to_h
    {
      events: events,
      count: count,
      offset: offset,
      limit: limit
    }
  end

  private
  def paginate?(format)
    format != :ical
  end
end
