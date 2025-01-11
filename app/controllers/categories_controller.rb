# frozen_string_literal: true

class CategoriesController < ApplicationController
  before_action :authenticate_restaurant!
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    # TODO: Show onl restaurant categories
    @categories = Category.all
  end

  def new
    @category = Category.new(category_type: params[:type])
  end

  def create
    position = Category.where(category_type: category_params[:category_type]).count + 1
    @category = Category.new(category_params)
    @category.restaurant_id = current_restaurant.id
    @category.position = position

    if @category.save
      flash[:notice] = 'Categoría agregada con éxito'
      render :new, status: :ok
    else
      flash[:alert] = 'Datos inválidos'
      render :new, status: :unprocessable_entity
    end
    flash.clear
  end

  def edit; end

  def update
    if @category.update(category_params)
      flash[:notice] = 'Categoría actualizada con éxito'
      redirect_to categories_path
    else
      flash[:alert] = 'Datos inválidos'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    flash[:notice] = 'Categoría eliminada con éxito'
    redirect_to categories_path
  end

  def reorder
    # TODO: Show onl restaurant categories
    category = Category.find(params[:id])
    order = params[:order]
    categories = Category.where(category_type: category.category_type)

    order.map do |id|
      categories.find(id).update(position: order.index(id) + 1)
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :category_type)
  end

  def set_category
    @category = Category.find(params[:id])
  end
end
