class CreateAllergensDishes < ActiveRecord::Migration[7.0]
  def change
    create_table :allergens_dishes do |t|
      t.references :allergen, null: false, foreign_key: true
      t.references :dish, null: false, foreign_key: true

      t.timestamps
    end
  end
end
