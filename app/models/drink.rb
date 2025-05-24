# frozen_string_literal: true

class Drink < ApplicationRecord
  extend Mobility

  broadcasts_refreshes_to ->(drink) { "restaurant_#{drink.restaurant_id}_drinks" }

  translates :name, type: :string
  translates :description, type: :text

  belongs_to :category, optional: true
  has_and_belongs_to_many :allergens, dependent: :destroy
  has_one_attached :image, dependent: :destroy
  belongs_to :restaurant

  scope :categorized_drinks, lambda { |restaurant_id, filter_allergens = []|
    scope = where(active: true, restaurant_id:)
            .joins(:category)
            .where(categories: { category_type: 'drinks' })

    if filter_allergens.present?
      excluded_drink_ids = joins(:allergens)
                           .where(allergens: { id: filter_allergens })
                           .distinct
                           .pluck(:id)

      scope = scope.where.not(id: excluded_drink_ids) if excluded_drink_ids.any?
    end

    scope.order('categories.position ASC', 'drinks.name ASC')
         .includes(:category)
         .load_async
         .group_by(&:category_id)
  }

  def self.query_drinks(restaurant_id:, query: nil)
    scope = where(restaurant_id:)
            .joins(:category)
            .where(categories: { category_type: 'drinks' }, restaurant_id:)
            .order('drinks.active DESC, drinks.name ASC')

    scope = scope.where('drinks.name ILIKE ?', "%#{query}%") if query.present?

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
    ImageProcessingService.new(file:, record: self, attachment_name: :image, wine: true).call
  end

  private

  def active_when_not_locked
    errors.add(:active, 'is not allowed when drink is locked') if lock? && active?
  end
end
