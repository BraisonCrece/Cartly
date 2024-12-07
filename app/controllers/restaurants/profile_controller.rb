# frozen_string_literal: true

module Restaurants
  class ProfileController < ApplicationController
    def edit
      @restaurant = current_restaurant
    end

    def update
      @restaurant = current_restaurant
      if @restaurant.update(restaurant_params)
        redirect_to profile_path, notice: 'Perfil actualizado con éxito'
      else
        render :edit, alert: 'Houbo un erro ao actualizar o perfil'
      end
    end

    private

    def restaurant_params
      params.require(:restaurant).permit(:name, :address, :phone, :province, :city, :logo)
    end
  end
end
