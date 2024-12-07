class Setting < ApplicationRecord
  belongs_to :restaurant

  def self.for_restaurant_id(restaurant_id)
    find_by(restaurant_id: restaurant_id) || create_for_restaurant_id(restaurant_id)
  end

  def self.use_menu_path?(restaurant_id)
    for_restaurant_id(restaurant_id).use_menu_path
  end

  def self.show_toggler?(restaurant_id)
    Rails.logger.info("show_toggler? #{for_restaurant_id(restaurant_id).show_toggler}")
    for_restaurant_id(restaurant_id).show_toggler
  end

  def self.show_locale_toggler?(restaurant_id)
    for_restaurant_id(restaurant_id).locale_toggler
  end

  def self.root_page(restaurant_id)
    for_restaurant_id(restaurant_id).root_page
  end

  def self.menu_price(restaurant_id)
    for_restaurant_id(restaurant_id).menu_price
  end

  def self.create_for_restaurant_id(restaurant_id)
    create(
      restaurant_id: restaurant_id,
      root_page: 'menu',
      show_toggler: true,
      locale_toggler: true,
      use_menu_path: false,
      menu_price: 12.5
    )
  end
end
