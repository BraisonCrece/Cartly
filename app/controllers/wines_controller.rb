class WinesController < ApplicationController
  before_action :set_wine, only: [:show, :edit, :update, :destroy]

  def index
    @wines = Wine.where(restaurant_id: current_restaurant.id)
  end

  def show; end

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
      redirect_to wines_control_panel_path,
                  notice: 'Viño engadido! Será automáticamente activado cando as traduccións rematen.'
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
      redirect_to wines_control_panel_path, notice: 'Viño actualizado con éxito.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @wine.destroy
    Thread.new do
      Translators::ProcessTranslationsService.new(@wine, :destroy).call
    end
    redirect_to wines_control_panel_path, notice: 'Viño eliminado!'
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
    @wine = Wine.find(params[:id])
  end

  def wine_params
    params.require(:wine).permit(:name, :description, :wine_type, :wine_origin_denomination_id, :price,
                                 :price_per_glass)
  end
end
