# frozen_string_literal: true

module Private
  class ControlPanelController < PrivateController
    include Pagy::Backend

    def food
      filter = params[:filter]
      query = params[:query]
      restaurant_id = current_restaurant.id
      @pagy, @dishes, @color = pagy_food(filter, query, restaurant_id)
    end

    def drinks
      filter = params[:filter]
      query = params[:query]
      restaurant_id = current_restaurant.id
      @pagy, @drinks, @color = pagy_drinks(filter, query, restaurant_id)
    end

    def toggle_active
      return unless ['dish', 'wine', 'drink'].include?(toggle_params[:type])

      model = toggle_params[:type].capitalize.constantize
      model
        .find_by(id: params[:id], restaurant_id: current_restaurant.id)
        .toggle!(:active)

      render turbo_stream: turbo_stream.replace(
        "#{params[:type]}_active_#{params[:id]}",
        partial: "#{params[:type]}_active",
        locals: { params[:type].to_sym => model.find(params[:id]) }
      )
    end

    private

    def pagy_food(filter, query, restaurant_id)
      case filter
      when 'daily'
        pagy, dishes = pagy_countless(Dish.daily_menu(restaurant_id:, query:), limit: 10)
        [pagy, dishes, { carta: 'not-selected', menu: 'selected' }]
      else
        pagy, dishes = pagy_countless(Dish.menu(restaurant_id:, query:), limit: 10)
        [pagy, dishes, { carta: 'selected', menu: 'not-selected' }]
      end
    end

    def pagy_drinks(filter, query, restaurant_id)
      case filter
      when 'wines'
        pagy, wines = pagy_countless(Wine.search(restaurant_id:, query: query), limit: 10)
        [pagy, wines, { drinks: 'not-selected', wines: 'selected' }]
      else
        pagy, drinks = pagy_countless(Drink.search(restaurant_id:, query: query), limit: 10)
        [pagy, drinks, { drinks: 'selected', wines: 'not-selected' }]
      end
    end

    def toggle_params
      params.permit(:id, :type)
    end
  end
end
