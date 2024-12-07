class AddProvinceAndCityToRestaurant < ActiveRecord::Migration[8.0]
  def change
    add_column :restaurants, :province, :string
    add_column :restaurants, :city, :string
  end
end
