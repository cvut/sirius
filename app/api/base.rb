require 'grape'
require 'json'

require 'api/events_endpoints'

module API
  class Base < Grape::API
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

    rescue_from Grape::Exceptions::Validation do |e|
      Rack::Response.new({ message: e.message }.to_json, 422, RACK_CONTENT_TYPE_HEADER).finish
    end

    rescue_from Sequel::NoMatchingRow do |e|
      Rack::Response.new({ message: e.message }.to_json, 404, RACK_CONTENT_TYPE_HEADER).finish
    end

    # rescue_from ActiveRecord::RecordNotFound do |e|
    #   Rack::Response.new({ message: "The item you are looking for does not exist."}.to_json, 404, RACK_CONTENT_TYPE_HEADER).finish
    # end

    # Mount your api classes here
    mount API::EventsEndpoints
  end
end
