class ProductsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :menu, :show]
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :set_categories, only: [:index, :new, :edit]

  def index
    @categorized_products = Product.categorized_products
    @denominations = WineOriginDenomination.all.includes(:wines)
    @available_colors = ["Blanco", "Tinto"].freeze
    @categorized_wines = Wine.categorized_wines(@denominations, @available_colors)
  end

  def menu
    @categorized_products = Product.menu_categorized_products
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    @product.active = true

    if params[:product][:picture]
      @product.process_image(params[:product][:picture])
    end

    if @product.save
      flash[:notice] = "Producto engadido!"
      render :new, status: :ok
      flash.clear
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @product = Product.find(params[:id])
  end

  def edit
    @product = Product.find(params[:id])
    @categories = Category.all
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      if params[:product][:picture]
        @product.process_image(params[:product][:picture])
      end
      redirect_to control_panel_path, notice: "Producto editado con éxito"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to control_panel_path, status: 303, notice: "Producto eliminado!"
  end

  def control_panel
    case params[:filter]
    when "menu"
      @products = Product.where(category: Category.where(category_type: "menu"))
    else
      @products = Product.where.not(category: Category.where(category_type: "menu"))
    end
  end

  def pages_control
    @settings = Setting.first
  end

  def toggle_active
    product = Product.find(params[:product_id])
    product.update(active: !product.active)
    render turbo_stream: turbo_stream.replace("product_active_#{product.id}", partial: "products/active", locals: { product: product })
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def set_categories
    @categories = Category.all
  end

  def product_params
    params.require(:product).permit(:title, :description, :prize, :category_id, :picture, allergen_ids: [])
  end
end
