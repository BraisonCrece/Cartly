# frozen_string_literal: true

# Controller for managing dish-related actions
module Public
  class ProductsController < ApplicationController
    before_action :set_restaurant

    WINE_COLORS = ['Blanco', 'Tinto'].freeze

    def menu
      @categorized_dishes = Dish.categorized_dishes(@restaurant.id)
      @categories = Category.menu
      @categorized_wines = Wine.grouped_by_type_and_denomination(@restaurant.id)
    end

    def daily
      @categorized_dishes = Dish.menu_categorized_dishes(@restaurant.id)
      @categories = Category.daily
    end

    private

    def set_restaurant
      @restaurant = Restaurant.find_by(id: params[:restaurant_id])
      redirect_to root_path unless @restaurant
    end
  end
end
