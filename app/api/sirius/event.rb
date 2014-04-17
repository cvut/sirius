module Sirius
  class Event < Grape::API
    resource :events do

      desc 'Test resource'
      get do
        ::Event.all
      end
    end

  end
end
