# frozen_string_literal: true

# Controller for managing restaurant settings
class SettingsController < ApplicationController
  before_action :authenticate_restaurant!
  before_action :set_restaurant
  before_action :set_settings

  def edit
    @settings = @restaurant.setting
  end

  def update
    @settings = @restaurant.setting
    if @settings.update(setting_params)
      redirect_to settings_path, notice: 'Configuración actualizada con éxito'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_restaurant
    @restaurant = current_restaurant
  end

  def set_settings
    @settings = @restaurant.setting || @restaurant.create_setting
  end

  def setting_params
    params.require(:setting).permit(:root_page, :show_toggler, :locale_toggler, :menu_price, :phone_number, :mobile)
  end
end
