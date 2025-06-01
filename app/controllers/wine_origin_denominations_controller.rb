# frozen_string_literal: true

class WineOriginDenominationsController < AdminController
  before_action :authenticate_restaurant!
  before_action :set_denomination, only: [:show, :edit, :update, :destroy]

  def index
    @denominations = WineOriginDenomination.where(restaurant_id: current_restaurant.id)
    @form_frame_tag = "#{current_restaurant.id}_wine_denomination_form"
    @denominations_list_frame_tag = "#{current_restaurant.id}_wine_denominations_list"
  end

  def show
    render @denomination
  end

  def new
    @denomination = WineOriginDenomination.new
  end

  def edit; end

  def create
    @denomination = WineOriginDenomination.new(wine_origin_denomination_params)
    @denomination.restaurant_id = current_restaurant.id

    if @denomination.save
      render turbo_stream: [
        turbo_stream.replace("#{current_restaurant.id}_wine_denomination_form", partial: 'form'),
        turbo_stream.append("#{current_restaurant.id}_wine_denominations_list", partial: 'wine_origin_denomination', locals: { wine_origin_denomination: @denomination }),
        turbo_notification('Denominación creada exitosamente', type: :success),
      ]
    else
      render turbo_stream: [
        turbo_stream.replace("#{current_restaurant.id}_wine_denomination_form", partial: 'form'),
        turbo_notification('Ha ocurrido un error al crear la denominación', type: :error),
      ], status: :unprocessable_entity
    end
  end

  def update
    if @denomination.update(wine_origin_denomination_params)
      render turbo_stream: [
        turbo_stream.replace(@denomination),
        turbo_notification('La denominación de origen se ha actualizado con éxito', type: :success),
      ]
    else
      render turbo_stream: [
        turbo_stream.replace(@denomination),
        turbo_notification('Ha ocurrido un error al actualizar la denominación de origen', type: :alert),
      ], status: :unprocessable_entity
    end
  end

  def destroy
    if @denomination.destroy
      render turbo_stream: [
        turbo_stream.remove(@denomination),
        turbo_notification('La denominación se ha eliminado con éxito', type: :success),
      ]
    else
      render turbo_stream: [
        turbo_notification('Ha ocurrido un error al eliminar la denominación', type: :alert),
      ], status: :unprocessable_entity
    end
  end

  private

  def set_denomination
    @denomination = WineOriginDenomination.find_by(id: params[:id], restaurant_id: current_restaurant.id)
    return unless @denomination.nil?

    redirect_to admin_denominations_path, alert: 'No se encontró la denominación'
  end

  def wine_origin_denomination_params
    params.require(:wine_origin_denomination).permit(:name)
  end
end
