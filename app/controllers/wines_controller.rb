# frozen_string_literal: true

class WinesController < AdminController
  before_action :authenticate_restaurant!, except: [:index, :show]
  before_action :set_wine, only: [:edit, :update, :destroy]
  before_action :block_write_actions!, only: [:create, :update, :destroy, :toggle_active]

  def index
    @wines = Wine.where(restaurant_id: current_restaurant.id)
  end

  def show
    @wine = Wine.find(params[:id])
  end

  def new
    @wine = Wine.new
    @denominations = WineOriginDenomination.where(restaurant_id: current_restaurant.id)
  end

  def edit
    @denominations = WineOriginDenomination.where(restaurant_id: current_restaurant.id)
  end

  def create
    @wine = Wine.new(wine_params).tap do |wine|
      wine.restaurant_id = current_restaurant.id
      wine.active = false
      wine.lock_it!
    end

    Thread.new do
      Translators::ProcessTranslationsService.new(@wine, :create).call
    end

    @wine.process_wine(params[:wine][:image]) if params[:wine][:image]

    if @wine.save
      redirect_to(
        control_panel_products_path(filter: 'wines'),
        notice: 'El vino se ha creado correctamente! Será desbloqueado en cuanto terminen las traducciones :)'
      )
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @wine.update(wine_params)
      if description_changed?
        Thread.new do
          Translators::ProcessTranslationsService.new(@wine, :update).call
        end
      end
      @wine.process_wine(params[:wine][:image]) if params[:wine][:image]
      redirect_to(
        control_panel_products_path(filter: 'wines'),
        notice: 'El vino se ha actualizado correctamente.'
      )
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @wine.destroy
    render turbo_stream: [
      turbo_stream.remove(@wine),
      turbo_notification('El vino se ha eliminado correctamente.'),
    ]
  end

  def control_panel
    @wines = Wine.where(restaurant_id: current_restaurant.id)
  end

  def toggle_active
    wine = Wine.find(params[:wine_id])
    wine.update(active: !wine.active)
    render turbo_stream: turbo_stream.replace("wine_active_#{wine.id}", partial: 'wines/active', locals: { wine: })
  end

  private

  def description_changed?
    @wine.previous_changes.include?('description')
  end

  def set_wine
    restaurant_id = params[:restaurant_id] || current_restaurant&.id
    @wine = Wine.find_by(id: params[:id], restaurant_id:)
    return unless @wine.nil?

    redirect_to control_panel_products_path(filter: 'wines'), alert: 'El vino no se ha encontrado.'
  end

  def wine_params
    params.require(:wine).permit(:name, :description, :wine_type, :wine_origin_denomination_id, :price,
                                 :price_per_glass)
  end
end
