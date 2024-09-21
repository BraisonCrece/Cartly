class ControlPanelController < ApplicationController
  before_action :authenticate_user!
  include Pagy::Backend

  def index
    filter = params[:filter]
    query = params[:query]
    @pagy, @products, @color = pagy_products(filter, query)
  end

  def toggle_active
    product = Product.find(params[:product_id])
    product.update(active: !product.active)

    render turbo_stream: turbo_stream.replace(
      "product_active_#{product.id}",
      partial: 'products/active',
      locals: { product: }
    )
  end

  private

  def pagy_products(filter, query)
    case filter
    when 'daily'
      pagy, products = pagy_countless(Product.daily_menu(query:), limit: 10)
      [pagy, products, { carta: 'not-selected', menu: 'selected' }]
    else
      pagy, products = pagy_countless(Product.not_daily_menu(query:), limit: 10)
      [pagy, products, { carta: 'selected', menu: 'not-selected' }]
    end
  end
end
