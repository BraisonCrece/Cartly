class SpecialMenusController < ApplicationController
  before_action :authenticate_restaurant!
  before_action :set_special_menu, only: [:show, :edit, :update, :destroy]

  def index
    @special_menus = SpecialMenu.where(restaurant_id: current_restaurant.id)
  end

  def new
    @special_menu = SpecialMenu.new
  end

  def create
    @special_menu = SpecialMenu.new(special_menu_params)
    @special_menu.restaurant_id = current_restaurant.id
    if @special_menu.save
      redirect_to special_menus_path, notice: t('.success')
    else
      render :new, alert: t('.error')
    end
  end

  def edit
  end

  def update
    if @special_menu.update(special_menu_params)
      redirect_to special_menus_path, notice: t('.success')
    else
      render :edit, alert: t('.error')
    end
  end

  def destroy
    @special_menu.destroy
    redirect_to special_menus_path, notice: t('.success')
  end

  def toggle_active
    @special_menu = SpecialMenu.find_by(id: params[:special_menu_id], restaurant_id: current_restaurant.id)
    @special_menu.toggle(:active)
    @special_menu.save
    render turbo_stream: turbo_stream.replace("special_menu_active_#{@special_menu.id}",
                                              partial: 'special_menus/active',
                                              locals: { special_menu: @special_menu })
  end

  private

  def set_special_menu
    @special_menu = SpecialMenu.find_by(id: params[:id], restaurant_id: current_restaurant.id)
    return unless @special_menu.nil?

    redirect_to special_menus_path, alert: t('.not_found')
  end

  def special_menu_params
    params.require(:special_menu).permit(:name, :description, :price)
  end
end
