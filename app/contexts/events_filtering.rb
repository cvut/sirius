require 'role_playing'
require 'core_ext/then_if'

require 'paginated_dataset'
require 'date_filtered_dataset'
##
# Filters events by page (offset, limit)
# depending on a requested format.
#
class EventsFiltering
  include RolePlaying::Context
  using MethodChain

  # @param [Sequel::Dataset<Event>]
  def initialize(dataset)
    @dataset = dataset
  end

  def call(params: {}, format: :jsonapi)
    [DateFilteredDataset, PaginatedDataset].played_by(@dataset) do |dataset|
      dataset
        .filter_by_date(from: params[:from], to: params[:to])
        .then_if(paginate?) { |d| d.paginate(offset: params[:offset], limit: params[:limit]) }
    end
  end

  private
  def paginate?
    format != :ical
  end
end
