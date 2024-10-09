class AddLockToDishes < ActiveRecord::Migration[7.0]
  def change
    add_column :dishes, :lock, :boolean, default: false
  end
end
