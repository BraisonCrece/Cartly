class CreateAllergensDrinks < ActiveRecord::Migration[8.0]
  def change
    create_table :allergens_drinks do |t|
      t.references :allergen, null: false, foreign_key: true
      t.references :drink, null: false, foreign_key: true
    end

    add_index :allergens_drinks, [:allergen_id, :drink_id], unique: true
  end
end
