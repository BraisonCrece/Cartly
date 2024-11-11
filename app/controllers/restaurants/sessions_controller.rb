# frozen_string_literal: true

class Restaurants::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  # before_action :set_restaurant, only: %i[new create]

  around_action :switch_locale
  after_action :set_session_locale

  def switch_locale(&action)
    I18n.with_locale(:en, &action)
  end

  def set_session_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)

    # En lugar de usar el redirect por defecto de Devise
    respond_to do |format|
      format.html { redirect_to control_panel_path }
      format.json { render :show, status: :ok, location: resource }
    end
  end

  # DELETE /resource/sign_out
  def destroy
    restaurant_id = current_restaurant&.id
    super do
      @stored_restaurant_id = restaurant_id
    end
  end

  protected

  def after_sign_out_path_for(_scope)
    root_path(restaurant_id: @stored_restaurant_id)
  end

  # def set_restaurant
  #   @restaurant = Restaurant.find(params[:restaurant_id])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
