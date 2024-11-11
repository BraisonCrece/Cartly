class DynamicRouterController < ApplicationController
  def call
    if Setting.root_page == 'menu'
      redirect_to menu_path(restaurant_id: params[:restaurant_id] || current_restaurant&.id)
    else
      redirect_to carta_path(restaurant_id: params[:restaurant_id] || current_restaurant&.id)
    end
  end
end
