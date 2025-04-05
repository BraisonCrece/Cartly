# frozen_string_literal: true

class WineOriginDenominationsController < ApplicationController
  before_action :authenticate_restaurant!
  before_action :set_denomination, only: [:show, :edit, :update, :destroy]

  def index
    @denominations = WineOriginDenomination.where(restaurant_id: current_restaurant.id)
  end

  def show; end

  def new
    @denomination = WineOriginDenomination.new
  end

  def edit; end

  def create
    @denomination = WineOriginDenomination.new(wine_origin_denomination_params)
    @denomination.restaurant_id = current_restaurant.id

    if @denomination.save
      flash[:notice] = t('.success')
      render :new
      flash.clear
    else
      flash[:alert] = t('.error')
      render :new, status: :unprocessable_entity
      flash.clear
    end
  end

  def update
    if @denomination.update(wine_origin_denomination_params)
      redirect_to denominations_path, notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @denomination.destroy
    redirect_to denominations_path, notice: t('.success')
  end

  private

  def set_denomination
    @denomination = WineOriginDenomination.find_by(id: params[:id], restaurant_id: current_restaurant.id)
    return unless @denomination.nil?

    redirect_to denominations_path, alert: t('.not_found')
  end

  def wine_origin_denomination_params
    params.require(:wine_origin_denomination).permit(:name)
  end
end
