# frozen_string_literal: true

class AddRestaurantIdToTables < ActiveRecord::Migration[7.0]
  def change
    add_reference :dishes, :restaurant, null: true, foreign_key: true
    add_reference :special_menus, :restaurant, null: true, foreign_key: true
    add_reference :wines, :restaurant, null: true, foreign_key: true
    add_reference :wine_origin_denominations, :restaurant, null: true, foreign_key: true
    add_reference :settings, :restaurant, null: true, foreign_key: true
  end
end
