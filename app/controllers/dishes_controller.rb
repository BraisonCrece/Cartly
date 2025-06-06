# frozen_string_literal: true

class DishesController < ApplicationController
  before_action :authenticate_restaurant!, except: [:show]
  before_action :set_dish, only: [:show, :edit, :update, :destroy]

  def new
    @dish = Dish.new
  end

  def create
    @dish = Dish.new(dish_params)
    @dish.restaurant_id = current_restaurant.id
    request_translations(@dish, :create) if ENV['GEMINI_KEY'].present?
    @dish.process_image(params[:dish][:picture]) if params[:dish][:picture]

    if @dish.save
      redirect_to control_panel_products_path(filter: 'food'), notice: 'Plato creado exitosamente :)'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit; end

  def update
    if @dish.update(dish_params)
      request_translations(@dish, :update) if ENV['GEMINI_KEY'].present? && title_or_description_changed?

      @dish.process_image(params[:dish][:picture]) if params[:dish][:picture]
      redirect_to control_panel_products_path(filter: 'food'), notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dish.destroy
    render turbo_stream: [
      turbo_stream.remove(@dish),
      turbo_stream.prepend(
        'notifications',
        partial: 'shared/notification',
        locals: { notice: t('.success') }
      ),
    ]
  end

  private

  def request_translations(dish, action)
    if action.in? [:create, :update]
      dish.active = false
      dish.lock_it!
    end
    Thread.new do
      Translators::ProcessTranslationsService.new(dish, action).call
    end
  end

  def title_or_description_changed?
    @dish.previous_changes.include?('title') || @dish.previous_changes.include?('description')
  end

  def set_dish
    restaurant_id = params[:restaurant_id] || current_restaurant&.id
    @dish = Dish.find_by(id: params[:id], restaurant_id:)

    return unless @dish.nil?

    redirect_to control_panel_products_path(filter: 'food'), alert: 'Plato no encontrado'
  end

  def dish_params
    params.require(:dish).permit(
      :title_es, :description_es, :prize, :category_id, :special_menu_id,
      :picture, :per_gram, :per_kilo, :per_unit, dietary_labels: [], allergen_ids: []
    )
  end
end
