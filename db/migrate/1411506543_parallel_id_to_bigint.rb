Sequel.migration do
  up do
    set_column_type :events, :parallel_id, Bignum
  end

  down do
    set_column_type :events, :parallel_id, Fixnum
  end
end
