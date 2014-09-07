require 'grape'
require 'json'

require 'errors_helper'
require 'sirius_api'
require 'api/events_endpoints'
module API
  class Base < Grape::API
    extend ErrorsHelper

    CONTENT_TYPE = "application/vnd.api+json"
    RACK_CONTENT_TYPE_HEADER = {"content-type" => CONTENT_TYPE}
    HTTP_STATUS_CODES = Rack::Utils::HTTP_STATUS_CODES.invert

    prefix 'api'
    version 'v1', using: :path

    # content_type :jsonapi, CONTENT_TYPE
    content_type :jsonapi, 'application/json'
    format :jsonapi

    content_type :ical, 'text/calendar; charset=utf-8'
    formatter :ical, lambda { |object, env| object.to_ical }

    rescue_status Grape::Exceptions::ValidationErrors, 400
    rescue_status Sequel::NoMatchingRow, 404

    # Mount your api classes here
    mount API::EventsEndpoints
  end
end
