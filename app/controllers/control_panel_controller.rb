# frozen_string_literal: true

# Controller for managing the control panel
# It includes the pagy gem for pagination
# It handles the dishes and wines
class ControlPanelController < ApplicationController
  before_action :authenticate_restaurant!
  include Pagy::Backend

  def dishes
    filter = params[:filter]
    query = params[:query]
    restaurant_id = current_restaurant.id
    @pagy, @dishes, @color = pagy_dishes(filter, query, restaurant_id)
  end

  def wines
    query = params[:query]
    restaurant_id = current_restaurant.id
    @pagy, @wines = pagy_wines(query, restaurant_id)
  end

  def toggle_active
    if params[:dish_id]
      toggle_dish_active
    elsif params[:wine_id]
      toggle_wine_active
    end
  end

  private

  def pagy_dishes(filter, query, restaurant_id)
    case filter
    when 'daily'
      pagy, dishes = pagy_countless(Dish.daily_menu(restaurant_id:, query:), limit: 10)
      [pagy, dishes, { carta: 'not-selected', menu: 'selected' }]
    else
      pagy, dishes = pagy_countless(Dish.menu(restaurant_id:, query:), limit: 10)
      [pagy, dishes, { carta: 'selected', menu: 'not-selected' }]
    end
  end

  def pagy_wines(query, restaurant_id)
    pagy, wines = pagy_countless(Wine.search(restaurant_id:, query: query), limit: 10)
    [pagy, wines]
  end

  def toggle_dish_active
    dish = Dish.find_by(id: params[:dish_id], restaurant_id: current_restaurant.id)
    dish.toggle!(:active)

    render turbo_stream: turbo_stream.replace(
      "dish_active_#{dish.id}",
      partial: 'dish_active',
      locals: { dish: }
    )
  end

  def toggle_wine_active
    wine = Wine.find_by(id: params[:wine_id], restaurant_id: current_restaurant.id)
    wine.toggle!(:active)

    render turbo_stream: turbo_stream.replace(
      "wine_active_#{wine.id}",
      partial: 'wine_active',
      locals: { wine: }
    )
  end
end
