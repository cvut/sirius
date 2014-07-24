require 'role_playing'
require 'core_ext/then'

##
# Filters dataset by starting date and end date.
class DateFilteredDataset < RolePlaying::Role
  # @param [Date,DateTime,String]
  # @param [Date,DateTime,String]
  # @return [Sequel::Dataset] filtered dataset
  def filter_by_date(from: nil, to: nil)

    self.then_if(from) { |d| d.where('starts_at >= ?', from) }
        .then_if(to) { |d| d.where('ends_at <= ?', to) }
  end
end
