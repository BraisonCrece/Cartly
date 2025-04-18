# frozen_string_literal: true

class CategoriesController < ApplicationController
  before_action :authenticate_restaurant!
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @categories = Category.where(restaurant_id: current_restaurant.id)
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
      request_translations(@category) if ENV['GEMINI_KEY'].present?
      redirect_to categories_path, notice: t('.success')
    else
      flash[:alert] = t('.invalid')
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      request_translations(@category) if ENV['GEMINI_KEY'].present?
      flash[:notice] = t('.success')
      redirect_to categories_path
    else
      flash[:alert] = t('.invalid')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      render turbo_stream: [
        turbo_stream.remove(@category),
        turbo_stream.prepend('notifications', partial: 'shared/notification', locals: { notice: t('.success') }),
      ]
    else
      # TODO: translate
      render turbo_stream: [
        turbo_stream.prepend(
          'notifications',
          partial: 'shared/notification',
          locals: { alert: 'Erro ao eliminar a categoria', type: :alert }
        ),
      ]
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
