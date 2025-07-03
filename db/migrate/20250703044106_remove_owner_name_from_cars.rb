class RemoveOwnerNameFromCars < ActiveRecord::Migration[7.1]
  def change
    remove_column :cars, :owner_name, :string
  end
end
