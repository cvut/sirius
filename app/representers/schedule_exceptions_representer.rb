require 'roar/decorator'
require 'roar/json/json_api'
require 'schedule_exception_representer'

class ScheduleExceptionsRepresenter < Roar::Decorator
  include Roar::JSON

  attr_reader :exceptions

  hash :meta, exec_context: :decorator
  collection :exceptions, decorator: ScheduleExceptionRepresenter

  def initialize(exceptions, **options)
    @options = options
    @exceptions = exceptions
    super self
  end

  protected

  attr_reader :options

  def meta
    {
      count: options[:count],
      offset: options[:offset],
      limit: options[:limit],
    }
  end
end
