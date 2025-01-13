# frozen_string_literal: true

class Wine < ApplicationRecord
  broadcasts_refreshes_to ->(stream) { stream.class.broadcast_target_default }

  belongs_to :wine_origin_denomination
  belongs_to :restaurant
  has_one_attached :image

  validates :price_per_glass, numericality: { greater_than: 0 }, allow_nil: true
  validate :active_when_not_locked

  scope :grouped_by_type_and_denomination, lambda { |restaurant_id|
    includes(:wine_origin_denomination)
      .where(active: true, restaurant_id:)
      .select('wines.*, wine_origin_denominations.name as denomination_name')
      .joins(:wine_origin_denomination)
      .order(:wine_type, 'wine_origin_denominations.name', :name)
      .group_by(&:wine_type)
      .transform_values do |wines|
        wines.group_by(&:denomination_name)
      end
  }

  def self.search(restaurant_id:, query: nil)
    scope = where(restaurant_id:)
            .order('wines.active DESC, wines.name ASC')

    scope = scope.where('wines.name ILIKE ?', "%#{query}%") if query.present?

    scope.load_async
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
  def process_wine(file)
    ImageProcessingService.new(file: file, record: self, attachment_name: :image, wine: true).call
  end

  private

  def active_when_not_locked
    errors.add(:active, 'is not allowed when wine is locked') if lock? && active?
  end
end
