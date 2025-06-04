# frozen_string_literal: true

class Drink < ApplicationRecord
  extend Mobility

  broadcasts_refreshes_to ->(drink) { "restaurant_#{drink.restaurant_id}_drinks" }
  
  after_update_commit :broadcast_lock_status_change, if: :saved_change_to_lock?

  translates :name, type: :string
  translates :description, type: :text

  belongs_to :category, optional: true
  has_and_belongs_to_many :allergens, dependent: :destroy
  has_one_attached :image, dependent: :destroy
  belongs_to :restaurant

  scope :categorized_drinks, lambda { |restaurant_id, filter_allergens = []|
    scope = where(active: true, restaurant_id:)
            .joins(:category)
            .where(categories: { category_type: 'drinks', restaurant_id: })

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

  scope :for_restaurant, ->(restaurant_id) { where(restaurant_id:) }
  scope :with_drinks_category, ->(restaurant_id) { joins(:category).where(categories: { category_type: 'drinks', restaurant_id: }) }
  scope :search_by_name, ->(query) { where('drinks.name ILIKE ?', "%#{query}%") if query.present? }
  scope :ordered_by_status, -> { order('drinks.active DESC, drinks.name ASC') }
  scope :by_category, ->(category_id) { where(category_id:) if category_id != 'all' && category_id.present? }

  def self.query_drinks(restaurant_id:, query: nil, category: 'all')
    for_restaurant(restaurant_id)
      .with_drinks_category(restaurant_id)
      .ordered_by_status
      .search_by_name(query)
      .by_category(category)
      .load_async
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
    ImageProcessingService.new(file:, record: self, attachment_name: :image, portrait: true).call
  end

  private

  def active_when_not_locked
    errors.add(:active, 'is not allowed when drink is locked') if lock? && active?
  end
  
  def broadcast_lock_status_change
    broadcast_replace_to "restaurant_#{restaurant_id}_control_panel_drinks",
                        target: self,
                        partial: "control_panel/drink",
                        locals: { drink: self }
  end
end
