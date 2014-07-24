require 'models/update_log'

Fabricator(:update_log) do
  type Sirius::UpdateLogType::PARALLEL_PARTIAL_UPDATE

end
