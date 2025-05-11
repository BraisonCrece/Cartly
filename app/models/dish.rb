# frozen_string_literal: true

class Dish < ApplicationRecord
  extend Mobility
  broadcasts_refreshes_to ->(stream) { stream.class.broadcast_target_default }

  translates :title, type: :string
  translates :description, type: :text

  belongs_to :category, optional: true
  has_and_belongs_to_many :allergens, dependent: :destroy
  has_one_attached :picture, dependent: :destroy
  belongs_to :restaurant

  validates :title_es, :description_es, presence: true
  validate :active_when_not_locked

  scope :categorized_dishes, lambda { |restaurant_id|
    where(active: true, restaurant_id:)
      .joins(:category)
      .where(categories: { category_type: 'menu' })
      .order('categories.position ASC', 'dishes.title ASC')
      .load_async
      .group_by(&:category_id)
  }

  scope :menu_categorized_dishes, lambda { |restaurant_id|
    where(active: true, restaurant_id:)
      .joins(:category)
      .where(categories: { category_type: 'daily' })
      .order('categories.position ASC', 'dishes.title ASC')
      .load_async
      .group_by(&:category_id)
  }

  def self.query(restaurant_id:, query: nil)
    scope = where(restaurant_id:)
            .joins(:category)
            .where(restaurant_id:)
            .order('dishes.active DESC, dishes.title ASC')

    scope = scope.where('dishes.title ILIKE ?', "%#{query}%") if query.present?

    scope.load_async
  end

  def self.daily_menu(restaurant_id:, query: nil)
    scope = where(restaurant_id:)
            .joins(:category)
            .where(categories: { category_type: 'daily' }, restaurant_id:)
            .order('dishes.active DESC, dishes.title ASC')

    scope = scope.where('dishes.title ILIKE ?', "%#{query}%") if query.present?

    scope.load_async
  end

  def self.menu(restaurant_id:, query: nil)
    scope = where(restaurant_id:)
            .joins(:category)
            .where(categories: { category_type: 'menu' }, restaurant_id:)
            .order('dishes.active DESC, dishes.title ASC')

    scope = scope.where('dishes.title ILIKE ?', "%#{query}%") if query.present?

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
    ImageProcessingService.new(file:, record: self, attachment_name: :picture).call
  end

  private

  def active_when_not_locked
    errors.add(:active, 'is not allowed when dish is locked') if lock? && active?
  end
end
