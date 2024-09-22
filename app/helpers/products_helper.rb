# frozen_string_literal: true

# Helper methods for products
module ProductsHelper
  def render_measure(product)
    return '€/Kg' if product.per_kilo
    return '€/100gr' if product.per_gram
    return '€/ud' if product.per_unit

    '€'
  end
end
