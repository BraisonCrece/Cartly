# frozen_string_literal: true

module SpecialMenus
  class DishesController < ApplicationController
    def new
      @dish = Dish.new
      @special_menu = SpecialMenu.find(params[:special_menu_id])
    end

    def create
      @dish = Dish.new(dish_params)
      @dish.restaurant = current_restaurant
      @dish.active = false
      @dish.lock_it!

      Thread.new do
        Translators::ProcessTranslationsService.new(@dish, :create).call
      end

      @dish.process_image(params[:dish][:picture]) if params[:dish][:picture]

      if @dish.save
        redirect_to special_menus_path, notice: 'Plato engadido ao menú especial con éxito.'
      else
        render :new, status: :unprocessable_entity, alert: 'Erro ao engadir o plato ao menú especial.'
      end
    end

    def edit
      @dish = Dish.find(params[:id])
      @special_menu = SpecialMenu.find(params[:special_menu_id])
    end

    def update
      @dish = Dish.find(params[:id])

      if @dish.update(dish_params)
        if title_or_description_changed?
          Thread.new do
            Translators::ProcessTranslationsService.new(@dish, :update).call
          end
        end

        @dish.process_image(params[:dish][:picture]) if params[:dish][:picture]

        redirect_to special_menus_path, notice: 'Plato actualizado con éxito.'
      else
        render :edit, status: :unprocessable_entity, alert: 'Erro ao actualizar o plato.'
      end
    end

    def destroy
      @dish = Dish.find(params[:id])
      @dish.destroy

      Thread.new do
        Translators::ProcessTranslationsService.new(@dish, :destroy).call
      end

      redirect_to special_menus_path, status: 303, notice: 'Plato eliminado con éxito.'
    end

    private

    def dish_params
      params.require(:dish).permit(
        :id, :title, :description, :price, :prize, :picture, :special_menu_id,
        :per_gram, :per_kilo, :per_unit, allergen_ids: []
      )
    end

    def title_or_description_changed?
      @dish.previous_changes.include?('title') || @dish.previous_changes.include?('description')
    end
  end
end
