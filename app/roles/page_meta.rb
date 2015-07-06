##
# Decorates the given object with {#page_meta} attribute.
class PageMeta < SimpleDelegator

  attr_reader :page_meta

  ##
  # @param object [Object] the object (typically an enumerable) to be decorated.
  # @param limit [Integer]
  # @param offset [Integer]
  # @param count [Integer] _total_ number of records.
  # @return a decorated object.
  #
  def initialize(object, limit:, offset:, count:)
    super object
    @page_meta = {
      limit: limit,
      offset: offset,
      count: count,
    }
  end

end
