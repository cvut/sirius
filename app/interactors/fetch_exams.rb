require 'interactors/fetch_resource'

class FetchExams < FetchResource

  def perform(**args)
    super(resource: :exams, **args)
  end

end
