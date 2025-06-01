# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :authenticate_restaurant!
  around_action :force_spanish_locale

  private

  def force_spanish_locale(&)
    I18n.with_locale(:es, &)
  end
end
