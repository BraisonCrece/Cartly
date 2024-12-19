class AllergensController < ApplicationController
  before_action :authenticate_restaurant!
  before_action :set_allergen, only: %i[ edit update destroy ]

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
  end

  def update
    if @allergen.update(allergen_params)
      redirect_to allergens_path
    else
      render :edit
    end
  end

  def destroy
    @allergen.destroy
    redirect_to allergens_path, status: 303, notice: 'Alérgeno eliminado!'
  end

  private

  def set_allergen
    @allergen = Allergen.find_by(id: params[:id], restaurant_id: current_restaurant.id)
    if @allergen.nil?
      redirect_to allergens_path, alert: 'Alérgeno non atopado.'
    end
  end

  def allergen_params
    params.require(:allergen).permit(:name, :icon)
  end
end
