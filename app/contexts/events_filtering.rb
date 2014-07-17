require 'role_playing'
require 'refinements/method_chain'

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
        .then(-> { format != :ical }) { |d| d.paginate(offset: params[:offset], limit: params[:limit]) }
    end
  end

end
