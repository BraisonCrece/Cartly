# frozen_string_literal: true

class Restaurants::ConfirmationsController < Devise::ConfirmationsController
  protected

  def after_confirmation_path_for(_resource_name, _resource)
    new_restaurant_session_path
  end
end