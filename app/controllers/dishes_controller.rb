# frozen_string_literal: true

# Controller for managing dish-related actions
class DishesController < ApplicationController
  before_action :authenticate_restaurant!, except: %i[index menu show]
  before_action :set_dish, only: %i[edit update destroy]
  before_action :set_categories, only: %i[index new edit]

  WINE_COLORS = %w[Blanco Tinto].freeze

  def index
    @restaurant = Restaurant.find(params[:restaurant_id])
    @categorized_dishes = Dish.categorized_dishes(@restaurant.id)
    @special_menus = SpecialMenu.active(@restaurant.id)
    @categories = Category.menu(@restaurant.id)
    @denominations = WineOriginDenomination.all.includes(:wines)
    @categorized_wines = Wine.categorized_wines(@restaurant.id, @denominations, WINE_COLORS)
  end

  def menu
    @categorized_dishes = Dish.menu_categorized_dishes(params[:restaurant_id])
    @menu_categories = Category.daily(params[:restaurant_id])
  end

  def new
    @dish = Dish.new
  end

  def create
    @dish = Dish.new(dish_params)
    @dish.restaurant_id = current_restaurant.id
    @dish.active = false
    @dish.lock_it!

    Thread.new do
      Translators::ProcessTranslationsService.new(@dish, :create).call
    end

    @dish.process_image(params[:dish][:picture]) if params[:dish][:picture]

    if @dish.save
      flash[:notice] = 'Plato engadido! Será automáticamente activado cando as traduccións rematen.'
      redirect_to control_panel_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @dish = Dish.find(params[:id])
  end

  def edit
    @categories = Category.all
  end

  def update
    if @dish.update(dish_params)

      if title_or_description_changed?
        Thread.new do
          Translators::ProcessTranslationsService.new(@dish, :update).call
        end
      end

      @dish.process_image(params[:dish][:picture]) if params[:dish][:picture]
      redirect_to control_panel_path, notice: 'Plato editado con éxito'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dish.destroy

    Thread.new do
      Translators::ProcessTranslationsService.new(@dish, :destroy).call
    end

    redirect_to control_panel_path, status: 303, notice: 'Plato eliminado!'
  end

  # TODO: Move this to the SettingsController
  def pages_control
    @settings = Setting.first
  end

  private

  def title_or_description_changed?
    @dish.previous_changes.include?('title') || @dish.previous_changes.include?('description')
  end

  def set_dish
    restaurant_id = params[:restaurant_id] || current_restaurant&.id
    @dish = Dish.find_by!(id: params[:id], restaurant_id:)
  end

  def set_categories
    @categories = Category.all
  end

  def dish_params
    params.require(:dish).permit(
      :title, :description, :prize, :category_id, :special_menu_id,
      :picture, :per_gram, :per_kilo, :per_unit, allergen_ids: []
    )
  end
end
