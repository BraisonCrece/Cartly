# frozen_string_literal: true

module ViewsHelper
  def products?(restaurant_id, active: true)
    if active
      dishes = Dish.where(restaurant_id: restaurant_id, active: true).any?
      wines = Wine.where(restaurant_id: restaurant_id, active: true).any?
    else
      dishes = Dish.where(restaurant_id: restaurant_id).any?
      wines = Wine.where(restaurant_id: restaurant_id).any?
    end

    dishes || wines
  end
end
