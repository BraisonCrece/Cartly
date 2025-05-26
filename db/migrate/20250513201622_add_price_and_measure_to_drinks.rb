class AddPriceAndMeasureToDrinks < ActiveRecord::Migration[8.0]
  def change
    add_column :drinks, :price, :decimal, precision: 10, scale: 2
    add_column :drinks, :measure, :decimal, precision: 10, scale: 2
    add_column :drinks, :unit, :string
  end
end
