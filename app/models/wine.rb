# frozen_string_literal: true

class Wine < ApplicationRecord
  extend Mobility

  broadcasts_refreshes_to ->(wine) { "restaurant_#{wine.restaurant_id}_wines" }

  after_update_commit :broadcast_lock_status_change, if: :saved_change_to_lock?

  belongs_to :wine_origin_denomination
  belongs_to :restaurant
  has_one_attached :image

  validates :price_per_glass, numericality: { greater_than: 0 }, allow_nil: true
  validate :active_when_not_locked

  translates :description, type: :string

  scope :for_restaurant, ->(restaurant_id) { where(restaurant_id:) }
  scope :search_by_name, ->(query) { where('wines.name ILIKE ?', "%#{query}%") if query.present? }
  scope :ordered_by_status, -> { order('wines.active DESC, wines.name ASC') }
  scope :by_denomination, ->(denomination_id) { where(wine_origin_denomination_id: denomination_id) if denomination_id != 'all' && denomination_id.present? }

  def self.search(restaurant_id:, query: nil, denomination: 'all')
    for_restaurant(restaurant_id)
      .ordered_by_status
      .search_by_name(query)
      .by_denomination(denomination)
      .load_async
  end

  def self.denominations_by_type(restaurant_id)
    denominations = WineOriginDenomination.joins(:wines)
                                          .where(restaurant_id:, wines: { active: true })
                                          .distinct
                                          .includes(:wines)

    grouped = { 'Tinto' => [], 'Blanco' => [] }

    denominations.each do |denomination|
      grouped['Tinto'] << denomination if denomination.wines.where(wine_type: 'Tinto', active: true, restaurant_id:).exists?
      grouped['Blanco'] << denomination if denomination.wines.where(wine_type: 'Blanco', active: true, restaurant_id:).exists?
    end

    grouped
  end

  def self.categorized_wines(restaurant_id, denominations, available_colors)
    wines_by_color_and_denomination = {}
    available_colors.each do |color|
      wines_by_color_and_denomination[color] = {}
      denominations.each do |denomination|
        wines = denomination.wines.where(active: true, wine_type: color, restaurant_id:).order(name: :asc)
        wines_by_color_and_denomination[color][denomination.id] = wines unless wines.blank?
      end
    end
    wines_by_color_and_denomination
  end

  def lock_it!
    update(lock: true)
  end

  # Image procesing before attach, allowed formats [:jpg, :png]
  def process_wine(file, saver: 85)
    ImageProcessingService.new(
      file: file,
      record: self,
      attachment_name: :image,
      portrait: true,
      saver: saver
    ).call
  end

  private

  def active_when_not_locked
    errors.add(:active, 'is not allowed when wine is locked') if lock? && active?
  end

  def broadcast_lock_status_change
    broadcast_replace_to "restaurant_#{restaurant_id}_control_panel_wines",
                         target: self,
                         partial: 'control_panel/wine',
                         locals: { wine: self }
  end
end
