class SpecialMenu < ApplicationRecord
  broadcasts_refreshes

  has_many :dishes

  scope :active, -> { where(active: true) }
  scope :active_dishes, -> { dishes.where(active: true) }
end
