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

  def initialize(events, **options)
    @options = options
    @decorator = EventsDecorator.new(self)
    @events = events
  end

  # FIXME: this should be handled on API's level
  def to_ical
    FormatEventsIcal.perform(events: events).ical
  end

  protected
  attr_reader :options
  def links
    {
      'posts.author' => {
        href: "#{options[:base_url]}/authors/{posts.author}", type: 'authors'
      }
    }
  end

  class EventsDecorator < Roar::Decorator
    include Roar::Representer::JSON
    hash :links
    collection :events, decorator: EventRepresenter
  end
end
