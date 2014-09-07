require 'grape'
require 'warden'
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
    default_format :jsonapi

    content_type :ical, 'text/calendar; charset=utf-8'
    formatter :ical, lambda { |object, env| object.to_ical }

    rescue_status Grape::Exceptions::ValidationErrors, 400
    rescue_status Sequel::NoMatchingRow, 404, message: 'Resource not found'
    rescue_status SiriusApi::Errors::Authentication, 401
    rescue_status SiriusApi::Errors::Authorization, 403

    use Warden::Manager do |manager|
      manager.default_strategies :access_token
      # manager.store = false
      manager.failure_app = lambda { |env| raise SiriusApi::Errors::Authentication, env['warden'].message }
    end

    # Mount your api classes here
    mount API::EventsEndpoints
  end
end
