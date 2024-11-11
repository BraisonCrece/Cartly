# frozen_string_literal: true

class RenameUsersToRestaurantas < ActiveRecord::Migration[7.2]
  def change
    rename_table :users, :restaurants
    add_column :restaurants, :name, :string
    add_column :restaurants, :address, :string
    add_column :restaurants, :phone, :string
    add_column :restaurants, :description, :text
  end
end
