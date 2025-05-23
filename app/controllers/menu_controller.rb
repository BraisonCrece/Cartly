# frozen_string_literal: true

class MenuController < ApplicationController
  WINE_COLORS = ['Tinto', 'Blanco'].freeze

  def menu
    @restaurant = Restaurant.find_by(id: params[:restaurant_id])
    return redirect_to root_path unless @restaurant

    filter_allergens = filter_params[:allergens].presence || []
    search_query = filter_params[:query].presence || ''

    @categories = Category.menu(@restaurant.id)
    @drink_categories = Category.drinks(@restaurant.id)
    @denominations = WineOriginDenomination.all.includes(:wines)

    @categorized_dishes = Dish.categorized_dishes(@restaurant.id, filter_allergens, search_query)
    @categorized_drinks = Drink.categorized_drinks(@restaurant.id)
    @categorized_wines = Wine.categorized_wines(@restaurant.id, @denominations, WINE_COLORS)
  end

  def daily_menu
    @restaurant = Restaurant.find_by(id: params[:restaurant_id])
    return redirect_to root_path unless @restaurant

    @categories = Category.daily(@restaurant.id)
    @categorized_dishes = Dish.menu_categorized_dishes(params[:restaurant_id])
  end

  private

  def filter_params
    params.permit(:allergens, :query)
  end
end
