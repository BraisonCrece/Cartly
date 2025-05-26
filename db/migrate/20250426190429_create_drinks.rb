class CreateDrinks < ActiveRecord::Migration[8.0]
  def change
    create_table :drinks do |t|
      t.string :name
      t.text :description
      t.boolean :active, default: true
      t.boolean :lock, default: false
      t.references :category, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
