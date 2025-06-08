# frozen_string_literal: true

# Controller for managing the control panel
# It includes the pagy gem for pagination
# It handles the dishes and wines
class ControlPanelController < AdminController
  before_action :authenticate_restaurant!
  before_action :block_write_actions!, only: [:toggle_active]
  include Pagy::Backend

  def products
    @filter = params[:filter].presence || 'food'
    @category = params[:category].presence || 'all'
    @query = params[:query]

    @selected = { name: @filter, path: selected_path(@filter) }
    set_filter_options
    @category_options = ControlPanel::CategoryOptionsService.call(@filter,
                                                                  drink_categories: @drink_categories,
                                                                  wine_denominations: @wine_denominations)
    @pagy, @products = paginate_products
  end

  def toggle_active
    product = find_product
    product.toggle!(:active)

    render turbo_stream: turbo_stream.replace(
      "#{product.class.name.downcase}_active_#{product.id}",
      partial: "#{product.class.name.downcase}_active",
      locals: { product.class.name.downcase.to_sym => product }
    )
  end

  private

  def selected_path(type)
    case type
    when 'food'
      new_dish_path
    when 'drinks'
      new_drink_path
    when 'wines'
      new_wine_path
    end
  end

  def set_filter_options
    case @filter
    when 'drinks'
      @drink_categories = Category.drinks_for_restaurant(current_restaurant.id)
    when 'wines'
      @wine_denominations = Wine.denominations_by_type(current_restaurant.id)
    end
  end

  def paginate_products
    scope = case @filter
            when 'food'
              get_dish_scope
            when 'drinks'
              Drink.query_drinks(restaurant_id: current_restaurant.id, query: @query, category: @category)
            else
              Wine.search(restaurant_id: current_restaurant.id, query: @query, denomination: @category)
            end

    pagy_countless(scope, limit: 10)
  end

  def get_dish_scope
    case @category
    when 'daily'
      Dish.daily_menu(restaurant_id: current_restaurant.id, query: @query)
    when 'menu'
      Dish.menu(restaurant_id: current_restaurant.id, query: @query)
    else
      Dish.query(restaurant_id: current_restaurant.id, query: @query)
    end
  end

  def find_product
    if params[:dish_id]
      Dish.find_by!(id: params[:dish_id], restaurant_id: current_restaurant.id)
    elsif params[:wine_id]
      Wine.find_by!(id: params[:wine_id], restaurant_id: current_restaurant.id)
    elsif params[:drink_id]
      Drink.find_by!(id: params[:drink_id], restaurant_id: current_restaurant.id)
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
