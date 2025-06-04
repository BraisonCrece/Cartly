# frozen_string_literal: true

# Controller for managing the control panel
# It includes the pagy gem for pagination
# It handles the dishes and wines
class ControlPanelController < AdminController
  before_action :authenticate_restaurant!
  include Pagy::Backend

  def products
    query = params[:query]
    restaurant_id = current_restaurant.id
    filter = params[:filter].presence || 'food'
    @category = params[:category].presence || 'all'
    @selected = { name: filter, path: selected_path(filter) }
    @drink_categories = Category.where(restaurant_id: restaurant_id, category_type: 'drinks').order(:position) if filter == 'drinks'
    @wine_denominations = get_wine_denominations_by_type(restaurant_id) if filter == 'wines'
    @pagy, @products = pagy_products(filter, query, @category, restaurant_id)
  end

  def toggle_active
    if params[:dish_id]
      toggle_dish_active
    elsif params[:wine_id]
      toggle_wine_active
    elsif params[:drink_id]
      toggle_drink_active
    end
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

  def pagy_products(filter, query, category, restaurant_id)
    case filter
    when 'food'
      dish_finders = {
        'daily' => -> { Dish.daily_menu(restaurant_id:, query:) },
        'menu' => -> { Dish.menu(restaurant_id:, query:) },
        'all' => -> { Dish.query(restaurant_id:, query:) },
      }
      finder = dish_finders[category] || dish_finders['all']
      pagy_countless(finder.call, limit: 10)
    when 'drinks'
      scope = Drink.query_drinks(restaurant_id:, query:)
      scope = scope.where(category_id: category) if category != 'all' && category.present?
      pagy_countless(scope, limit: 10)
    else
      scope = Wine.search(restaurant_id:, query: query)
      scope = scope.where(wine_origin_denomination_id: category) if category != 'all' && category.present?
      pagy_countless(scope, limit: 10)
    end
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

  def toggle_drink_active
    drink = Drink.find_by(id: params[:drink_id], restaurant_id: current_restaurant.id)
    drink.toggle!(:active)

    render turbo_stream: turbo_stream.replace(
      "drink_active_#{drink.id}",
      partial: 'drink_active',
      locals: { drink: }
    )
  end

  def get_wine_denominations_by_type(restaurant_id)
    denominations = WineOriginDenomination.joins(:wines)
                                         .where(restaurant_id: restaurant_id, wines: { active: true })
                                         .distinct
                                         .includes(:wines)

    grouped = { 'Tinto' => [], 'Blanco' => [] }
      
    denominations.each do |denomination|
      if denomination.wines.where(wine_type: 'Tinto', active: true, restaurant_id: restaurant_id).exists?
        grouped['Tinto'] << denomination
      end
      if denomination.wines.where(wine_type: 'Blanco', active: true, restaurant_id: restaurant_id).exists?
        grouped['Blanco'] << denomination
      end
    end
      
    grouped
  end
end
