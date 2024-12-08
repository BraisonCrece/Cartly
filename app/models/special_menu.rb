class SpecialMenu < ApplicationRecord
  broadcasts_refreshes

  has_many :dishes, dependent: :destroy

  scope :active, lambda { |restaurant_id|
    where(active: true, restaurant_id: restaurant_id)
  }
  scope :active_dishes, lambda { |restaurant_id|
    dishes.where(active: true, restaurant_id:)
  }
end
