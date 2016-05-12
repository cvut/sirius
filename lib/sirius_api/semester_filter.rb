require 'core_ext/then'

# @deprecated
module SiriusApi
  class SemesterFilter

    def filter(dataset, params)
      faculty_id = params[:faculty]
      dataset.then_if(faculty_id) { |d| d.where(faculty: faculty_id) }
    end
  end
end
