# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include NotificationHelper

  around_action :switch_locale

  def switch_locale(&)
    if params[:locale]
      locale = params[:locale] || I18n.default_locale
      session[:locale] = locale
    end

    I18n.with_locale(session[:locale], &)
  end
end
