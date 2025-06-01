# frozen_string_literal: true

module Restaurants
  class ProfileController < AdminController
    def edit
      @restaurant = current_restaurant
    end

    def update
      @restaurant = current_restaurant

      if @restaurant.update(restaurant_params)
        process_images
        redirect_to control_panel_products_path(filter: 'food'), notice: t('.success')
      else
        render :edit, alert: t('.error')
      end
    end

    private

    def process_images
      [params[:restaurant][:logo], params[:restaurant][:logo_white]].each do |image|
        next unless image

        @restaurant.process_image(
          file: image,
          attachment_name: image == params[:restaurant][:logo] ? :logo : :logo_white
        )
      end
    end

    def restaurant_params
      params.require(:restaurant).permit(:name, :address, :phone, :province, :city, :logo, :logo_white)
    end
  end
end
