# frozen_string_literal: true

class Restaurants::SessionsController < Devise::SessionsController
  rate_limit to: 4, within: 1.minute, only: :create

  around_action :switch_locale
  after_action :set_session_locale

  def switch_locale(&)
    I18n.with_locale(:en, &)
  end

  def set_session_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)

    respond_to do |format|
      format.html { redirect_to control_panel_products_path(filter: 'food') }
      format.json { render :show, status: :ok, location: resource }
    end
  end

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
end
