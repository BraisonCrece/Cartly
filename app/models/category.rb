# frozen_string_literal: true

class Category < ApplicationRecord
  extend Mobility
  translates :name, type: :string

  has_many :dishes, dependent: :destroy
  has_many :drinks, dependent: :destroy

  before_create :set_position

  scope :menu, lambda { |restaurant_id|
    joins(:dishes)
      .where(category_type: 'menu', restaurant_id: restaurant_id, dishes: { active: true })
      .distinct
      .order(position: :asc)
  }
  scope :daily, lambda { |restaurant_id|
    joins(:dishes)
      .where(category_type: 'daily', restaurant_id: restaurant_id, dishes: { active: true })
      .distinct
      .order(position: :asc)
  }

  scope :drinks, lambda { |restaurant_id|
    joins(:drinks)
      .where(category_type: 'drinks', restaurant_id: restaurant_id)
      .distinct
      .order(position: :asc)
  }

  private

  def set_position
    self.position = Category.where(restaurant_id: restaurant_id, category_type: category_type).count + 1
  end
end
