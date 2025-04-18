class Allergen < ApplicationRecord
  extend Mobility

  has_and_belongs_to_many :dishes, dependent: :destroy
  has_one_attached :icon, dependent: :destroy do |attachable|
    attachable.variant :thumb, resize_to_limit: [80, 80]
  end

  translates :name, type: :string

  validates :name, :icon, presence: true
end
