class AddDietaryLabelsToDishes < ActiveRecord::Migration[8.0]
  def change
    add_column :dishes, :dietary_labels, :string, array: true, default: []
    add_index :dishes, :dietary_labels, using: :gin
  end
end
