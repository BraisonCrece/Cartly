# frozen_string_literal: true

class MenuController < ApplicationController
  WINE_COLORS = ['Tinto', 'Blanco'].freeze

  def menu
    @restaurant = Restaurant.find_by(id: params[:restaurant_id])
    return redirect_to root_path unless @restaurant

    handle_allergen_filters
    @has_active_products = active_products?

    @categories = Category.menu(@restaurant.id)
    @drink_categories = Category.drinks(@restaurant.id)
    @denominations = WineOriginDenomination.all.includes(:wines)

    @categorized_dishes = Dish.categorized_dishes(@restaurant.id, current_allergen_filters)
    @categorized_drinks = Drink.categorized_drinks(@restaurant.id, current_allergen_filters)
    @categorized_wines = Wine.categorized_wines(@restaurant.id, @denominations, WINE_COLORS)
  end

  def daily_menu
    @restaurant = Restaurant.find_by(id: params[:restaurant_id])
    return redirect_to root_path unless @restaurant

    handle_allergen_filters
    @has_active_products = active_products?

    @categories = Category.daily(@restaurant.id)
    @categorized_dishes = Dish.menu_categorized_dishes(@restaurant.id, current_allergen_filters)
  end

  private

  def active_products?
    @restaurant.dishes.where(active: true).exists? ||
      @restaurant.drinks.where(active: true).exists? ||
      @restaurant.wines.where(active: true).exists?
  end

  def handle_allergen_filters
    return unless params[:filter_applied] == 'true'

    if params[:allergens].present?
      session[:allergen_filters] = Array(params[:allergens]).map(&:to_i)
    else
      session.delete(:allergen_filters)
    end
  end

  def current_allergen_filters
    @current_allergen_filters ||= session[:allergen_filters] || []
  end

  def filter_params
    params.permit(:allergens, :filter_applied)
  end
end
