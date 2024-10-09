class AddUnitColumnsToDishes < ActiveRecord::Migration[7.0]
  def change
    add_column :dishes, :per_gram, :boolean, precision: 10, scale: 2, default: false
    add_column :dishes, :per_kilo, :boolean, precision: 10, scale: 2, default: false
    add_column :dishes, :per_unit, :boolean, default: false
  end
end
