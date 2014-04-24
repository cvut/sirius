require 'roar/representer/json'
require 'roar/decorator'

class BaseRepresenter < Roar::Decorator
  include Roar::Representer::JSON
end
