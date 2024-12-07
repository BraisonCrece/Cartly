# frozen_string_literal: true

class Restaurant < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: { message: 'É obrigatorio o uso dun email' }
  validates :email, uniqueness: { message: 'O email xa existe na base de datos', case_sensitive: false }
  validates :name, presence: true, length: { maximum: 255 }

  has_many :dishes, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :allergens, dependent: :destroy
  has_many :special_menus, dependent: :destroy
  has_many :wines, dependent: :destroy
  has_many :wine_origin_denominations, dependent: :destroy
  has_one :setting, dependent: :destroy
  has_one_attached :logo
end
