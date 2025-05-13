# frozen_string_literal: true

class DrinksController < ApplicationController
  before_action :authenticate_restaurant!, except: [:show]
  before_action :set_drink, only: [:show, :edit, :update, :destroy]

  def new
    @drink = Drink.new
  end

  def create
    @drink = Drink.new(drink_params)
    @drink.restaurant_id = current_restaurant.id
    request_translations(@drink, :create) if ENV['GEMINI_KEY'].present?
    @drink.process_image(params[:drink][:image]) if params[:drink][:image]

    if @drink.save
      redirect_to control_panel_products_path(filter: 'drinks'), notice: 'Bebida creada exitosamente :)'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit; end

  def update
    if @drink.update(drink_params)
      request_translations(@drink, :update) if ENV['GEMINI_KEY'].present? && name_or_description_changed?

      @drink.process_image(params[:drink][:image]) if params[:drink][:image]
      redirect_to control_panel_products_path(filter: 'drinks'), notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @drink.destroy
    render turbo_stream: [
      turbo_stream.remove(@drink),
      turbo_stream.prepend(
        'notifications',
        partial: 'shared/notification',
        locals: { notice: t('.success') }
      ),
    ]
  end

  private

  def request_translations(drink, action)
    if action.in? [:create, :update]
      drink.active = false
      drink.lock_it!
    end
    Thread.new do
      Translators::ProcessTranslationsService.new(drink, action).call
    end
  end

  def name_or_description_changed?
    @drink.previous_changes.include?('name') || @drink.previous_changes.include?('description')
  end

  def set_drink
    restaurant_id = params[:restaurant_id] || current_restaurant&.id
    @drink = Drink.find_by(id: params[:id], restaurant_id:)

    return unless @drink.nil?

    redirect_to control_panel_products_path(filter: 'drinks'), alert: 'Bebida no encontrada'
  end

  def drink_params
    params.require(:drink).permit(
      :name, :description, :category_id,
      :image, :active, allergen_ids: []
    )
  end
end
