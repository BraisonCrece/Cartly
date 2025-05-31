class AddConfirmableToRestaurants < ActiveRecord::Migration[8.0]
  def up
    add_column :restaurants, :confirmation_token, :string
    add_column :restaurants, :confirmed_at, :datetime
    add_column :restaurants, :confirmation_sent_at, :datetime
    add_column :restaurants, :unconfirmed_email, :string
    
    add_index :restaurants, :confirmation_token, unique: true
    
    # Confirm all existing restaurants
    Restaurant.update_all(confirmed_at: Time.current)
  end
  
  def down
    remove_index :restaurants, :confirmation_token
    remove_column :restaurants, :confirmation_token
    remove_column :restaurants, :confirmed_at
    remove_column :restaurants, :confirmation_sent_at
    remove_column :restaurants, :unconfirmed_email
  end
end
