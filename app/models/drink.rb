# frozen_string_literal: true

class Drink < ApplicationRecord
  # extend Mobility
  broadcasts_refreshes_to ->(drink) { "restaurant_#{drink.restaurant_id}_drinks" }
  # translates :name, type: :string
  # translates :description, type: :text

  belongs_to :category, optional: true
  has_and_belongs_to_many :allergens, dependent: :destroy
  has_one_attached :image, dependent: :destroy
  belongs_to :restaurant

  # validates :title_es, :description_es, presence: true
  # validate :active_when_not_locked

  scope :categorized_drinks, lambda { |restaurant_id|
    where(active: true, restaurant_id:)
      .joins(:category)
      .where(categories: { category_type: 'drinks' })
      .order('categories.position ASC', 'dishes.title ASC')
      .load_async
      .group_by(&:category_id)
  }

  def self.query_drinks(restaurant_id:, query: nil)
    scope = where(restaurant_id:)
            .joins(:category)
            .where(categories: { category_type: 'drinks' }, restaurant_id:)
            .order('drinks.active DESC, drinks.name ASC')

    scope = scope.where('dishes.name ILIKE ?', "%#{query}%") if query.present?

    scope.load_async
  end

  def lock_it!
    update(lock: true)
  end

  def unlock_it!
    update(lock: false)
  end

  # Image procesing before attach, allowed formats [:jpg, :png, :webp]
  def process_image(file)
    # change this to drink: true
    ImageProcessingService.new(file:, record: self, attachment_name: :picture, wine: true).call
  end

  private

  def active_when_not_locked
    errors.add(:active, 'is not allowed when drink is locked') if lock? && active?
  end
end
