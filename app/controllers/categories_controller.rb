# frozen_string_literal: true

class CategoriesController < AdminController
  before_action :authenticate_restaurant!
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @menu_categories = Category.where(category_type: 'menu', restaurant_id: current_restaurant.id)
    @daily_categories = Category.where(category_type: 'daily', restaurant_id: current_restaurant.id)
    @drinks_categories = Category.where(category_type: 'drinks', restaurant_id: current_restaurant.id)
    @category_form_frame_tag = 'category_form'
    @selected_category_type = params[:selected_type] || 'menu'
  end

  def new
    @category = Category.new(category_type: params[:type])
  end

  def show
    @category = Category.find(params[:id])
    render @category
  end

  def create
    position = Category.where(
      category_type: category_params[:category_type],
      restaurant_id: current_restaurant.id
    ).count + 1

    @category = Category.new(category_params)
    @category.restaurant_id = current_restaurant.id
    @category.position = position

    if @category.save
      reload_category_data
      request_translations(@category)
      section_frame_id = "#{@category.category_type}_section"
      section_list_id = "categories_#{@category.category_type}_list"
      section_partial = "#{@category.category_type}_categories_section"

      stream_actions = [].tap do |actions|
        actions << turbo_stream.action(:clear_form, 'category_name_es')
        if position != 1
          actions << turbo_stream.append(
            section_list_id,
            partial: 'categories/category',
            locals: { category: @category }
          )
        end
        actions << turbo_stream.replace(section_frame_id, partial: "categories/#{section_partial}") if position == 1
        actions << turbo_notification('Categoría creada exitosamente', type: :success)
      end

      render turbo_stream: stream_actions
    else
      render turbo_stream: [
        turbo_stream.replace("#{current_restaurant.id}_category_form", partial: 'categories/form', locals: { category: @category, selected_category_type: @category.category_type }),
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

  def last_category?(category)
    Category
      .where(category_type: category.category_type, restaurant_id: current_restaurant.id)
      .count
      .zero?
  end

  def destroy
    category_type = @category.category_type
    if @category.destroy
      stream_actions = [].tap do |actions|
        actions << if last_category?(@category)
                     turbo_stream.replace(
                       "#{category_type}_section",
                       partial: 'categories/empty_category_section',
                       locals: { category_type: category_type }
                     )
                   else
                     turbo_stream.remove(@category)
                   end

        actions << turbo_notification('La categoría se ha eliminado con éxito', type: :success)
      end

      render turbo_stream: stream_actions
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

  def reload_category_data
    @menu_categories = Category.where(category_type: 'menu', restaurant_id: current_restaurant.id)
    @daily_categories = Category.where(category_type: 'daily', restaurant_id: current_restaurant.id)
    @drinks_categories = Category.where(category_type: 'drinks', restaurant_id: current_restaurant.id)
  end

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
