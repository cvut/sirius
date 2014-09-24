require 'icalendar'
module IcalendarHelper
  ##
  # Convenient method to enforce strict parsing in specs
  def parse_icalendar(ics, strict: true, all: false)
    Icalendar::Parser.new(ics, strict).parse
  end
end
