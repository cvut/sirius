require 'interpipe/interactor'
require 'sirius/updated_parallels_finder'

class FetchUpdatedParallels
  include Interpipe::Interactor

  def setup(finder: Sirius::UpdatedParallelsFinder.new)
    @finder = finder
  end

  def perform(faculty_semester: nil, page_size: 100, fetch_all: true)
    updated_parallels = @finder.find_updated(faculty: faculty_semester.faculty, semester: faculty_semester.code, page_size: page_size)
    updated_parallels.auto_paginate = fetch_all
    @results = {kosapi_parallels: updated_parallels, faculty_semester: faculty_semester }
  end

end
