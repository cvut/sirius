require 'forwardable'

require 'roar/decorator'
require 'roar/json/json_api'
require 'event_representer'
require 'format_events_ical'

# FIXME: This is a temporary custom-made representer until Roar
# natively supports decorators for JSON API
class EventsRepresenter
  extend Forwardable # standard delegation

  def_delegators :@decorator, :to_json, :as_json, :to_hash
  attr_reader :events

  def initialize(events, singular: false, **options)
    @options = options
    @events = events

    decorator_class = singular ? SingularDecorator : CollectionDecorator
    @decorator = decorator_class.new(self)
  end

  # FIXME: this should be handled on API's level
  def to_ical
    FormatEventsIcal.perform(events: events).ical
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

  class CollectionDecorator < Roar::Decorator
    include Roar::Representer::JSON
    hash :meta
    collection :events, decorator: EventRepresenter
  end

  class SingularDecorator < Roar::Decorator
    include Roar::Representer::JSON
    # hash :links
    property :events, decorator: EventRepresenter
  end
end
