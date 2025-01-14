class CreateDrinks < ActiveRecord::Migration[8.0]
  def change
    create_table :drinks do |t|
      t.string :name
      t.string :description
      t.string :price
      t.boolean :active, default: true
      t.references :restaurant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
