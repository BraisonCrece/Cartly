class AddPrizeToDishes < ActiveRecord::Migration[7.0]
  def change
    add_column :dishes, :prize, :integer
  end
end
