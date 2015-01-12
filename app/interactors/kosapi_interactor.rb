require 'interpipe/interactor'
require 'kosapi_client'
require 'sirius/kosapi_client_registry'

class KOSapiInteractor
  include Interpipe::Interactor

  def setup(client: nil)
    @forced_client = client
  end

  protected

  def kosapi_client(faculty_semester)
    @forced_client || Sirius::KOSapiClientRegistry.instance.client_for_faculty(faculty_semester.faculty)
  end

end
