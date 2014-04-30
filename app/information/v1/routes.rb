module Sirius

  module V1
    class Routes < Grapevine::API

      version 'v1', using: :path

      # uncomment mount_helpers method and include all helpers you required from those declared in helpers folder
      # e.g. mount_helpers([::AppHelpers, ::ContextHelpers])
      #
      # mount_helpers([])

      # uncomment mount_helpers method and include all routes you required
      # e.g. mount_routes([AppName::V1::Routes, ::MyCustomRoutes])
      #
      # mount_routes([])

      resource :test_route do
        get '/' do
          { result: "this is the test route resource of v1" }
        end
      end
    end
  end
end
