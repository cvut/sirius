require 'role_playing'

class ImportedExam < RolePlaying::Role

  DEFAULT_EXAM_DURATION = 90.minutes

  def end_date
    exam = __getobj__
    if exam.end_date
      exam.end_date
    else
      exam.start_date + DEFAULT_EXAM_DURATION
    end
  end

  def event_type
    if term_type == :assessment
      'assessment'
    else
      'exam'
    end
  end

end
