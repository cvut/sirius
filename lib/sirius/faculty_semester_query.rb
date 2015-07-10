class FacultySemesterQuery

  def apply(resource, faculty_semester:, **rest)
    query = "course.faculty==#{faculty_semester.faculty};semester==#{faculty_semester.code}"
    resource.where(query)
  end

end
