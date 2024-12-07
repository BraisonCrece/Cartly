class RemoveRestaurantDataFromSettings < ActiveRecord::Migration[8.0]
  def change
    remove_column :settings, :phone_number
    remove_column :settings, :mobile
  end
end
