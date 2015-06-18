require 'models/faculty_semester'
require 'semesters_representer'
require 'api_helper'

module API
  class SemestersEndpoints < Grape::API
    helpers ApiHelper

    before do
      authenticate!
    end

    resource :semesters do
      params { use :pagination }

      get do
        represent_paginated(FacultySemester.dataset, SemestersRepresenter)
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
