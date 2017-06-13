require 'role_playing'
require 'core_ext/then'

##
# Filters dataset by starting date and end date.
class DateFilteredDataset < RolePlaying::Role
  ##
  # @param from [Date, DateTime, String]
  # @param to [Date, DateTime, String]
  # @param with_original_date [Boolean] whether to include original +starts_at-
  #        and +ends_at+ into the range.
  # @return [Sequel::Dataset] a filtered dataset.
  def filter_by_date(from: nil, to: nil, with_original_date: false)

    condition = ->(col, op, date) do
      sql = "#{col} #{op} :date"
      sql += " OR original_#{col} #{op} :date" if with_original_date
      Sequel.lit(sql, date: date)
    end

    self.then_if(from) { |d| d.where(condition['starts_at', '>=', from]) }
        .then_if(to) { |d| d.where(condition['ends_at', '<=', to]) }
  end
end
