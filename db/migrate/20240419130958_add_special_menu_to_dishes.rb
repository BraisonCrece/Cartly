class AddSpecialMenuToDishes < ActiveRecord::Migration[7.0]
  def change
    add_reference :dishes, :special_menu, null: true, foreign_key: true
  end
end
