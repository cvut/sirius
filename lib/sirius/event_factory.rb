require 'models/event'

module Sirius
  class EventFactory

    def initialize

    end

    def build_event(event_period)
      event = Event.new
      event.period = event_period
      event
    end
  end
end
