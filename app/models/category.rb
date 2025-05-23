# frozen_string_literal: true

class Category < ApplicationRecord
  extend Mobility
  translates :name, type: :string

  has_many :dishes, dependent: :destroy

  before_create :set_position

  scope :menu, -> { where(category_type: 'menu').order(position: :asc) }
  scope :daily, -> { where(category_type: 'daily').order(position: :asc) }

  private

  def set_position
    self.position = Category.where(restaurant_id: restaurant_id, category_type: category_type).count + 1
  end
end
