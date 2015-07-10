class SemesterPeriodDatesQuery

  def apply(resource, faculty_semester:, **rest)
    query = "startDate>=#{faculty_semester.starts_at};endDate<=#{faculty_semester.ends_at}"
    resource.where(query)
  end

end
