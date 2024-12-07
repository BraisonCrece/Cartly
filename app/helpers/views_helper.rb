# frozen_string_literal: true

module ViewsHelper
  def active_products?(restaurant_id)
    active_dishes = Dish.where(restaurant_id: restaurant_id, active: true).any?
    active_wines = Wine.where(restaurant_id: restaurant_id, active: true).any?

    active_dishes || active_wines
  end
end
