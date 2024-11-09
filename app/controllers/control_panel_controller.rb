class ControlPanelController < ApplicationController
  before_action :authenticate_restaurant!
  include Pagy::Backend

  def index
    filter = params[:filter]
    query = params[:query]
    @pagy, @dishes, @color = pagy_dishes(filter, query)
  end

  def toggle_active
    dish = Dish.find(params[:dish_id])
    dish.update(active: !dish.active)

    render turbo_stream: turbo_stream.replace(
      "dish_active_#{dish.id}",
      partial: 'dishes/active',
      locals: { dish: }
    )
  end

  private

  def pagy_dishes(filter, query)
    case filter
    when 'daily'
      pagy, dishes = pagy_countless(Dish.daily_menu(query:), limit: 10)
      [pagy, dishes, { carta: 'not-selected', menu: 'selected' }]
    else
      pagy, dishes = pagy_countless(Dish.not_daily_menu(query:), limit: 10)
      [pagy, dishes, { carta: 'selected', menu: 'not-selected' }]
    end
  end
end
