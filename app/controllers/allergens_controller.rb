class AllergensController < ApplicationController
  before_action :authenticate_restaurant!

  def index
    @allergens = Allergen.where(restaurant_id: current_restaurant.id)
  end

  def new
    @allergen = Allergen.new
  end

  def create
    @allergen = Allergen.new(allergen_params)
    @allergen.restaurant_id = current_restaurant.id

    if @allergen.save
      flash[:notice] = "Alérgeno agregado con éxito"
      render :new, status: :ok
      flash.clear
    else
      flash[:alert] = "Datos inválidos"
      render :new, status: :unprocessable_entity
      flash.clear
    end
  end

  def show
    @allergen = Allergen.find_by(id: params[:id], restaurant_id: current_restaurant.id)
  end

  def edit
    @allergen = Allergen.find_by(id: params[:id], restaurant_id: current_restaurant.id)
  end

  def update
    @allergen = Allergen.find_by(id: params[:id], restaurant_id: current_restaurant.id)
    if @allergen.update(allergen_params)
      redirect_to allergens_path
    else
      render :edit
    end
  end

  def destroy
    @allergen = Allergen.find_by(id: params[:id], restaurant_id: current_restaurant.id)
    @allergen.destroy
    redirect_to allergens_path, status: 303, notice: 'Alérgeno eliminado!'
  end

  private
  def allergen_params
    params.require(:allergen).permit(:name, :icon)
  end
end
