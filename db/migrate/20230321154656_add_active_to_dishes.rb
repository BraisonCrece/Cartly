class AddActiveToDishes < ActiveRecord::Migration[7.0]
  def change
    add_column :dishes, :active, :boolean
  end
end
