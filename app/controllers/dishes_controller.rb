# frozen_string_literal: true

# Controller for managing dish-related actions
class DishesController < ApplicationController
  before_action :authenticate_restaurant!, except: %i[index menu show]
  before_action :set_dish, only: %i[show edit update destroy]
  before_action :set_categories, only: %i[index new edit]

  WINE_COLORS = %w[Blanco Tinto].freeze

  def index
    @categorized_dishes = Dish.categorized_dishes
    @special_menus = SpecialMenu.active
    @categories = Category.menu
    @denominations = WineOriginDenomination.all.includes(:wines)
    @categorized_wines = Wine.categorized_wines(@denominations, WINE_COLORS)
  end

  def menu
    @categorized_dishes = Dish.menu_categorized_dishes
    @menu_categories = Category.daily
  end

  def new
    @dish = Dish.new
  end

  def create
    @dish = Dish.new(dish_params)
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
    @dish = Dish.find(params[:id])
    @categories = Category.all
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
      redirect_to control_panel_path, notice: 'Plato editado con éxito'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dish = Dish.find(params[:id])
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
    @dish = Dish.find(params[:id])
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
