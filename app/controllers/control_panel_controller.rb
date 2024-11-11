# frozen_string_literal: true

class ControlPanelController < ApplicationController
  before_action :authenticate_restaurant!
  include Pagy::Backend

  def index
    filter = params[:filter]
    query = params[:query]
    restaurant_id = current_restaurant.id
    @pagy, @dishes, @color = pagy_dishes(filter, query, restaurant_id)
  end

  def toggle_active
    dish = Dish.find_by(id: params[:dish_id], restaurant_id: current_restaurant.id)
    dish.update(active: !dish.active)

    render turbo_stream: turbo_stream.replace(
      "dish_active_#{dish.id}",
      partial: 'dishes/active',
      locals: { dish: }
    )
  end

  private

  def pagy_dishes(filter, query, restaurant_id)
    case filter
    when 'daily'
      pagy, dishes = pagy_countless(Dish.daily_menu(restaurant_id:, query:), limit: 10)
      [pagy, dishes, { carta: 'not-selected', menu: 'selected' }]
    else
      pagy, dishes = pagy_countless(Dish.not_daily_menu(restaurant_id:, query:), limit: 10)
      [pagy, dishes, { carta: 'selected', menu: 'not-selected' }]
    end
  end
end
