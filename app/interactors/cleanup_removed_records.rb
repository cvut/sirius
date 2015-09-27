class CleanupRemovedRecords

  def cleanup_records(seen_records, stored_ids, record_class)
    seen_ids = seen_records.map(&:id)
    missing_ids = stored_ids - seen_ids
    record_class.where(id: missing_ids, deleted_at: nil).update(deleted_at: Sequel.function(:NOW))
    missing_ids
  end
end
