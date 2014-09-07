module SiriusApi
  module Errors
    Authentication = Class.new(StandardError)
    Authorization = Class.new(StandardError)
  end
end
