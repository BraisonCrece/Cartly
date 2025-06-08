# frozen_string_literal: true

# Controller for managing restaurant settings
class SettingsController < AdminController
  before_action :authenticate_restaurant!
  before_action :set_restaurant
  before_action :set_settings
  before_action :block_write_actions!, only: [:update]

  def edit
    @settings = @restaurant.setting
  end

  def update
    @settings = @restaurant.setting
    if @settings.update(setting_params)
      redirect_to admin_settings_path, notice: t('.success')
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
