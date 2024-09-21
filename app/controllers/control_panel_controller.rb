class ControlPanelController < ApplicationController
  before_action :authenticate_user!
  def index
    filter = params[:filter]
    @products, @color = filter_products(filter)
  end

  def filter_products(filter)
    case filter
    when 'daily'
      [Product.daily_menu, { carta: 'not-selected', menu: 'selected' }]
    else
      [Product.not_daily_menu, { carta: 'selected', menu: 'not-selected' }]
    end
  end
end
