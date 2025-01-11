# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :dishes, dependent: :destroy

  scope :menu, -> { where(category_type: 'menu').order(position: :asc) }
  scope :daily, -> { where(category_type: 'daily').order(position: :asc) }
end
