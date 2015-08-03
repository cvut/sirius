require 'grape'
require 'warden'
require 'json'
require 'errors_helper'
require 'sirius_api'
require 'api/events_endpoints'
require 'api/schedule_exceptions_endpoints'
require 'api/search_endpoints'
require 'api/semesters_endpoints'

module API
  class Base < Grape::API
    extend ErrorsHelper

    HTTP_STATUS_CODES = Rack::Utils::HTTP_STATUS_CODES.invert

    prefix 'api'
    version 'v1', using: :path

    content_type :jsonapi, 'application/json; charset=utf-8'
    format :jsonapi
    default_format :jsonapi

    content_type :ical, 'text/calendar; charset=utf-8'
    formatter :ical, lambda { |object, env| object.to_ical }

    rescue_status Grape::Exceptions::ValidationErrors, 400
    rescue_status Sequel::NoMatchingRow, 404, message: 'Resource not found'
    rescue_status SiriusApi::Errors::Authentication, 401
    rescue_status SiriusApi::Errors::Authorization, 403

    use Warden::Manager do |manager|
      manager.default_strategies :local_token, :remote_oauth_server
      # manager.store = false
      manager.failure_app = lambda do |env|
        raise SiriusApi::Errors::Authentication, env['warden'].message || env['warden.errors'].values.join(' ')
      end
    end

    # Mount your api classes here
    mount API::EventsEndpoints
    mount API::ScheduleExceptionsEndpoints
    mount API::SearchEndpoints
    mount API::SemestersEndpoints
  end
end
