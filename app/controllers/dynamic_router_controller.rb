# frozen_string_literal: true

# This controller is responsible for routing to the correct page based on the root_page setting
class DynamicRouterController < ApplicationController
  def call
    if Setting.root_page(params[:restaurant_id]) == 'menu'
      redirect_to menu_path(restaurant_id: params[:restaurant_id] || current_restaurant&.id)
    else
      redirect_to carta_path(restaurant_id: params[:restaurant_id] || current_restaurant&.id)
    end
  end
end
