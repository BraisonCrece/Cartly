class Wine < ApplicationRecord
  broadcasts_refreshes

  belongs_to :wine_origin_denomination
  belongs_to :restaurant
  has_one_attached :image

  validates :price_per_glass, numericality: { greater_than: 0 }, allow_nil: true
  validate :active_when_not_locked

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
