# frozen_string_literal: true

# Helper methods for dishes
module DishesHelper
  def render_measure(dish)
    return '' unless dish.prize
    return '€/Kg' if dish.per_kilo
    return '€/100gr' if dish.per_gram
    return '€/ud' if dish.per_unit

    '€'
  end
end
