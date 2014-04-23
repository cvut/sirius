module Sirius
  class EventEndpoint < Grape::API
    helpers ApiHelper

    resource :events do

      desc 'Test resource'
      get do
        represent ::Event.all, with: EventRepresenter
      end
    end

  end
end
