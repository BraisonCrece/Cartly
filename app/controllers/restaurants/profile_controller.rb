module Restaurants
  class ProfileController < ApplicationController
    def edit
      @restaurant = current_restaurant
    end

    def update
      @restaurant = current_restaurant
      if @restaurant.update(restaurant_params)
        redirect_to dishes_control_panel_path, notice: t('.success')
      else
        render :edit, alert: t('.error')
      end
    end

    private

    def restaurant_params
      params.require(:restaurant).permit(:name, :address, :phone, :province, :city, :logo, :logo_white)
    end
  end
end
