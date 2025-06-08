# frozen_string_literal: true

class AllergensController < AdminController
  before_action :authenticate_restaurant!
  before_action :set_allergen, only: [:edit, :update, :destroy]
  before_action :block_write_actions!, only: [:create, :update, :destroy]

  def index
    @system_allergens = Allergen.where(restaurant_id: nil)
    @restaurant_allergens = Allergen.where(restaurant_id: current_restaurant.id)
  end

  def new
    @allergen = Allergen.new
  end

  def create
    @allergen = Allergen.new(allergen_params)
    @allergen.restaurant_id = current_restaurant.id

    if @allergen.save
      flash[:notice] = t('.success')
      render :new, status: :ok
    else
      flash[:alert] = t('.invalid')
      render :new, status: :unprocessable_entity
    end
    flash.clear
  end

  def show
    @allergen = Allergen.find_by(id: params[:id], restaurant_id: current_restaurant.id)
  end

  def edit; end

  def update
    if @allergen.update(allergen_params)
      redirect_to allergens_path, notice: t('.success')
    else
      render :edit
    end
  end

  def destroy
    @allergen.destroy
    redirect_to allergens_path, status: 303, notice: t('.success')
  end

  private

  def set_allergen
    @allergen = Allergen.find_by(id: params[:id], restaurant_id: current_restaurant.id)
    return unless @allergen.nil?

    redirect_to allergens_path, alert: t('.not_found')
  end

  def allergen_params
    params.require(:allergen).permit(:name, :icon)
  end
end
