require 'base_representer'
module EventRepresenter
  property :id
  property :name
  property :note
  property :sequence_number
  property :starts_at
  property :ends_at

  has_one :room
  has_one :course
  has_one :student
end
