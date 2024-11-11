# frozen_string_literal: true

# == Schema Category
#
# id                :bigint           not null, primary key
# name              :string
# category_type     :string
# restaurant_id     :bigint           not null
# created_at        :datetime         not null
# updated_at        :datetime         not null
# == End
class Category < ApplicationRecord
  belongs_to :restaurant
  has_many :dishes, dependent: :destroy

  scope :menu, ->(restaurant_id) { where(category_type: 'menu', restaurant_id:).order(created_at: :asc) }
  scope :daily, ->(restaurant_id) { where(category_type: 'daily', restaurant_id:).order(created_at: :asc) }
end
