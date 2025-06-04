# frozen_string_literal: true

class Dish < ApplicationRecord
  extend Mobility

  broadcasts_refreshes_to ->(dish) { "restaurant_#{dish.restaurant_id}_dishes" }
  after_update_commit :broadcast_lock_status_change, if: :saved_change_to_lock?

  translates :title, type: :string
  translates :description, type: :text

  belongs_to :category, optional: true
  has_and_belongs_to_many :allergens, dependent: :destroy
  has_one_attached :picture, dependent: :destroy
  belongs_to :restaurant

  validates :title_es, :description_es, presence: true
  validate :active_when_not_locked

  scope :categorized_dishes, lambda { |restaurant_id, filter_allergens = [], query_string = nil|
    scope = where(active: true, restaurant_id:)
            .joins(:category)
            .where(categories: { category_type: 'menu' })

    if filter_allergens.present?
      excluded_dish_ids = joins(:allergens)
                          .where(allergens: { id: filter_allergens })
                          .distinct
                          .pluck(:id)

      scope = scope.where.not(id: excluded_dish_ids) if excluded_dish_ids.any?
    end

    if query_string.present?
      scope = scope.where('dishes.title ILIKE ? OR dishes.description ILIKE ?',
                          "%#{query_string}%",
                          "%#{query_string}%")
    end

    scope.order('categories.position ASC', 'dishes.title ASC')
         .includes(:category)
         .load_async
         .group_by(&:category_id)
  }

  scope :menu_categorized_dishes, lambda { |restaurant_id, filter_allergens = []|
    scope = where(active: true, restaurant_id:)
            .joins(:category)
            .where(categories: { category_type: 'daily' })

    if filter_allergens.present?
      excluded_dish_ids = joins(:allergens)
                          .where(allergens: { id: filter_allergens })
                          .distinct
                          .pluck(:id)

      scope = scope.where.not(id: excluded_dish_ids) if excluded_dish_ids.any?
    end

    scope.order('categories.position ASC', 'dishes.title ASC')
         .includes(:category)
         .load_async
         .group_by(&:category_id)
  }

  scope :for_restaurant, ->(restaurant_id) { where(restaurant_id:) }
  scope :with_category_type, ->(type) { joins(:category).where(categories: { category_type: type }) }
  scope :search_by_title, ->(query) { where('dishes.title ILIKE ?', "%#{query}%") if query.present? }
  scope :ordered_by_status, -> { order('dishes.active DESC, dishes.title ASC') }

  def self.query(restaurant_id:, query: nil)
    for_restaurant(restaurant_id)
      .joins(:category)
      .ordered_by_status
      .search_by_title(query)
      .load_async
  end

  def self.daily_menu(restaurant_id:, query: nil)
    for_restaurant(restaurant_id)
      .with_category_type('daily')
      .ordered_by_status
      .search_by_title(query)
      .load_async
  end

  def self.menu(restaurant_id:, query: nil)
    for_restaurant(restaurant_id)
      .with_category_type('menu')
      .ordered_by_status
      .search_by_title(query)
      .load_async
  end

  def vegan?
    dietary_labels.include?(DietaryLabels::VEGAN)
  end

  def vegetarian?
    dietary_labels.include?(DietaryLabels::VEGETARIAN)
  end

  def lock_it!
    update(lock: true)
  end

  def unlock_it!
    update(lock: false)
  end

  # Image procesing before attach, allowed formats [:jpg, :png, :webp]
  def process_image(file, saver: 85)
    ImageProcessingService.new(file:, record: self, attachment_name: :picture, saver: saver).call
  end

  private

  def active_when_not_locked
    errors.add(:active, 'is not allowed when dish is locked') if lock? && active?
  end

  def broadcast_lock_status_change
    broadcast_replace_to "restaurant_#{restaurant_id}_control_panel_dishes",
                         target: self,
                         partial: 'control_panel/dish',
                         locals: { dish: self }
  end
end
