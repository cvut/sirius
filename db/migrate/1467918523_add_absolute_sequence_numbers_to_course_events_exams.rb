Sequel.migration do
  up do
    self[:events].where(source_type: ['course_event', 'exam']).update(absolute_sequence_number: 1)
  end

  down do
    self[:events].where(source_type: ['course_event', 'exam']).update(absolute_sequence_number: nil)
  end
end
