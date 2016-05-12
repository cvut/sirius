require 'api_helper'
require 'corefines'
require 'date_refinements'
require 'models/faculty_semester'
require 'representers/semester_days_representer'
require 'representers/semester_weeks_representer'
require 'representers/semesters_representer'
require 'sirius_api/semester_schedule'

module API
  class FacultiesEndpoints < Grape::API
    using Corefines::Object[:then, :else]
    using ::DateRefinements

    helpers ApiHelper

    helpers do
      def get_day(date)
        SiriusApi::SemesterSchedule.resolve_day(date, params[:faculty_id])
          .then { |it| SemesterDaysRepresenter.new(it) }
          .else { not_found! }
      end

      def get_week(date)
        SiriusApi::SemesterSchedule.resolve_week(date, params[:faculty_id])
          .then { |it| SemesterWeeksRepresenter.new(it) }
          .else { not_found! }
      end

      def check_faculty!(faculty_id)
        DB.select(true)
          .where(FacultySemester.where(faculty: faculty_id).exists)
          .single_value
          .else { error!({message: "Faculty with code #{faculty_id} not found"}, 404) }
      end
    end

    resource :faculties do

      params { requires :faculty_id, type: Integer, desc: 'Faculty code (5 digits)' }
      route_param :faculty_id do

        resource :schedule do

          resource :days do
            params { use :date_range }

            get do
              check_faculty! params[:faculty_id]
              SemesterDaysRepresenter.for_collection.new(
                SiriusApi::SemesterSchedule.resolve_days(params[:from], params[:to], params[:faculty_id]))
            end

            resource :current do
              get { get_day Date.today }
            end

            params { requires :date, type: Date, desc: 'Date to resolve' }
            route_param :date do
              get { get_day params[:date] }
            end
          end

          resource :weeks do
            params { use :date_range }

            get do
              check_faculty! params[:faculty_id]
              SemesterWeeksRepresenter.for_collection.new(
                SiriusApi::SemesterSchedule.resolve_weeks(params[:from], params[:to], params[:faculty_id]))
            end

            resource :current do
              get { get_week Date.today.start_of_week }
            end

            params do
              requires :year_cweek, type: String, year_cweek: true,
                desc: 'ISO 8601 week-based year and week number'
            end
            route_param :year_cweek do
              get { get_week Date.strptime(params[:year_cweek], '%G-%V') }
            end
          end
        end

        resource :semesters do
          params { use :pagination }

          get do
            check_faculty! params[:faculty_id]

            dataset = FacultySemester
              .where(faculty: params[:faculty_id])
              .eager(:semester_periods)
            represent_paginated(dataset, SemestersRepresenter)
          end

          params do
            requires :code, type: String, regexp: /[AB]\d{2}[12]/,
              desc: 'Semester code (e.g. B151)'
          end
          route_param :code do
            get do
              SemestersRepresenter.new ::FacultySemester.first!(
                faculty: params[:faculty_id], code: params[:code]
              )
            end
          end
        end
      end
    end
  end
end
