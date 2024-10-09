class AddCategoryIdToDishes < ActiveRecord::Migration[7.0]
  def change
    add_column :dishes, :category_id, :integer
  end
end
