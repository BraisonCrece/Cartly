class ControlPanelController < ApplicationController
  before_action :authenticate_user!
  include Pagy::Backend

  def index
    filter = params[:filter]
    @pagy, @products, @color = pagy_products(filter)
  end

  def pagy_products(filter)
    case filter
    when 'daily'
      pagy, products = pagy_countless(Product.daily_menu, limit: 10)
      [pagy, products, { carta: 'not-selected', menu: 'selected' }]
    else
      pagy, products = pagy_countless(Product.not_daily_menu, limit: 10)
      [pagy, products, { carta: 'selected', menu: 'not-selected' }]
    end
  end
end
