Sequel.migration do
  change do

    alter_table(:semester_periods) do
      add_column :irregular, TrueClass, default: false, null: false
    end

    # Set irregular to true for rows where first_day_override is not null.
    self[:semester_periods]
      .exclude(first_day_override: nil)
      .update(irregular: true)
  end
end
