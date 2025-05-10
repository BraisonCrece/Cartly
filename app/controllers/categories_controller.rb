# frozen_string_literal: true

class CategoriesController < ApplicationController
  before_action :authenticate_restaurant!
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @categories = Category.where(restaurant_id: current_restaurant.id)
    @menu_list_frame_tag = "#{current_restaurant.id}_menu_list"
    @daily_list_frame_tag = "#{current_restaurant.id}_daily_list"
    @drinks_list_frame_tag = "#{current_restaurant.id}_drinks_list"
    @category_form_frame_tag = "#{current_restaurant.id}_category_form"
  end

  def new
    @category = Category.new(category_type: params[:type])
  end

  def show
    @category = Category.find(params[:id])
    render @category
  end

  def create
    position = Category.where(category_type: category_params[:category_type]).count + 1
    @category = Category.new(category_params)
    @category.restaurant_id = current_restaurant.id
    @category.position = position

    if @category.save
      request_translations(@category)
      list_frame_id = "#{current_restaurant.id}_#{@category.category_type}_list"
      render turbo_stream: [
        turbo_stream.replace("#{current_restaurant.id}_category_form", partial: 'categories/form', locals: { category: @category }),
        turbo_stream.append(list_frame_id, partial: 'categories/category', locals: { category: @category }),
        turbo_notification('Categoría creada exitosamente', type: :success),
      ]
    else
      render turbo_stream: [
        turbo_stream.replace("#{current_restaurant.id}_category_form", partial: 'categories/form', locals: { category: @category }),
        turbo_notification('Ha ocurrido un error al crear la categoría', type: :alert),
      ], status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      request_translations(@category)
      render turbo_stream: [
        turbo_stream.replace(@category),
        turbo_notification('La categoría se ha actualizado con éxito', type: :success),
      ]
    else
      render turbo_stream: [
        turbo_stream.replace("#{current_restaurant.id}_category_form", partial: 'categories/form', locals: { category: @category }),
        turbo_notification('Ha ocurrido un error al actualizar la categoría', type: :alert),
      ], status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      render turbo_stream: [
        turbo_stream.remove(@category),
        turbo_notification('La categoría se ha eliminado con éxito', type: :success),
      ]
    else
      render turbo_stream: [
        turbo_notification('Ha ocurrido un error al eliminar la categoría', type: :alert),
      ], status: :unprocessable_entity
    end
  end

  def reorder
    category = Category.find_by(id: params[:id], restaurant_id: current_restaurant.id)
    order = params[:order]
    categories = Category.where(category_type: category.category_type, restaurant_id: current_restaurant.id)

    order.map do |id|
      categories.find(id).update(position: order.index(id) + 1)
    end
  end

  private

  def request_translations(category)
    return unless ENV['GEMINI_KEY'].present?

    Thread.new do
      Translators::NewItemTranslatorService
        .new(category)
        .call
    end
  end

  def category_params
    params.require(:category).permit(:name_es, :category_type)
  end

  def set_category
    @category = Category.find_by(id: params[:id], restaurant_id: current_restaurant.id)
  end
end
