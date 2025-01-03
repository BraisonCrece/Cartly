# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :dishes, dependent: :destroy

  scope :menu, -> { where(category_type: 'menu').order(created_at: :asc) }
  scope :daily, -> { where(category_type: 'daily').order(created_at: :asc) }
end
