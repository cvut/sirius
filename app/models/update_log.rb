require 'sirius/enums/update_log_type'

class UpdateLog < Sequel::Model

  def self.last_partial_update
    where(type: Sirius::UpdateLogType.to_numeric(Sirius::UpdateLogType::PARALLEL_PARTIAL_UPDATE)).last
  end

  def type
    Sirius::UpdateLogType.from_numeric(super)
  end

  def type=(new_type)
    super Sirius::UpdateLogType.to_numeric(new_type)
  end

end
