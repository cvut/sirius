Sequel.migration do
  up do
    set_column_type :events, :id, Bignum
  end

  down do
    set_column_type :events, :id, Fixnum
  end
end
