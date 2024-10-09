class ChangeDataTypeOfDishesPrize < ActiveRecord::Migration[7.0]
  def change
    change_column :dishes, :prize, :float
  end
end
