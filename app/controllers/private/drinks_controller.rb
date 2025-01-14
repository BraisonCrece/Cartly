# frozen_string_literal: true

module Private
  class DrinksController < PrivateController
    before_action :set_drink, only: [:show, :edit, :update, :destroy]

    def new
      @drink = Drink.new
    end

    def create
      @drink = Drink.new(drink_params)
      @drink.restaurant = current_restaurant
      if @drink.save
        redirect_to control_panel_path, notice: 'Bebida creada con éxito'
      else
        render :new
      end
    end

    def show; end

    def edit; end

    def update
      if @drink.update(drink_params)
        redirect_to control_panel_path, notice: 'Bebida actualizada con éxito'
      else
        render :edit
      end
    end

    def destroy
      @drink.destroy
      redirect_to control_panel_path, notice: 'Bebida eliminada con éxito'
    end

    private

    def drink_params
      params.require(:drink).permit(:name, :description, :price)
    end

    def set_drink
      @drink = Drink.find_by!(id: params[:id], restaurant: current_restaurant)
    end
  end
end
