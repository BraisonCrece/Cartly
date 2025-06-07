class AddStripeFieldsToRestaurants < ActiveRecord::Migration[8.0]
  def change
    add_column :restaurants, :stripe_customer_id, :string
    add_column :restaurants, :stripe_subscription_id, :string
    add_column :restaurants, :subscription_status, :string, default: 'inactive'
    add_column :restaurants, :subscription_current_period_end, :datetime

    add_index :restaurants, :stripe_customer_id
    add_index :restaurants, :stripe_subscription_id
    add_index :restaurants, :subscription_status
  end
end
