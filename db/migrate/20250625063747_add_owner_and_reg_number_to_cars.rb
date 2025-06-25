class AddOwnerAndRegNumberToCars < ActiveRecord::Migration[7.1]
  def change
    add_column :cars, :owner_name, :string
    add_column :cars, :registration_number, :string
  end
end
