require 'models/faculty_semester'
require 'semesters_representer'
require 'sirius_api/semester_filter'
require 'api_helper'

module API
  class SemestersEndpoints < Grape::API
    helpers ApiHelper

    helpers do
      params :faculty_filter do
        optional :faculty, type: Integer
      end
    end

    before do
      authenticate!
    end

    resource :semesters do
      params { use :pagination, :faculty_filter }

      get do
        filtered_dataset = SiriusApi::SemesterFilter.new.filter(FacultySemester.dataset, params)
        represent_paginated(filtered_dataset, SemestersRepresenter)
      end

      params do
        requires :faculty_semester, type: String, regexp: /\d{5}-[AB]\d{2}[12]/,
          desc: 'Faculty code and semester code connected with dash'
      end
      route_param :faculty_semester do
        get do
          faculty, semester = params[:faculty_semester].split('-')
          SemestersRepresenter.new ::FacultySemester.first!(faculty: faculty, code: semester)
        end
      end
    end
  end
end
