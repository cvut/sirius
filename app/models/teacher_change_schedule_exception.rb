require 'schedule_exception'

class TeacherChangeScheduleException < ScheduleException

  # Checks for `{username,12345,foo}` with optional spaces around braces and commas.
  # An empty list `{}` is also allowed.
  USERNAME_LIST_FORMAT = /^ *{ *(\w+(?: *, *\w+)*)? *} *$/.freeze
  USERNAME_DELIMITER = / *, */.freeze # username list delimiters - comas with optional spaces

  def apply_people_assign(event)
    if event.teacher_ids != parse_username_list(options['teacher_ids'])
      event.update(teacher_ids: options['teacher_ids'])
    end
  end

  private

  # XXX: This should be removed once schedule_exceptions.options is converted to jsonb.
  def parse_username_list(list)
    result = list.match(USERNAME_LIST_FORMAT)
    raise "Invalid username list format (#{list})." unless result
    (result[1] || '').split(USERNAME_DELIMITER)
  end
end
