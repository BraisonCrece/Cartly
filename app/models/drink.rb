# frozen_string_literal: true

class Drink < ApplicationRecord
  def self.search(restaurant_id:, query: nil)
    scope = where(restaurant_id:)
            .order('drinks.active DESC, drinks.name ASC')
    scope = scope.where('drinks.name ILIKE ?', "%#{query}%") if query.present?
    scope.load_async
  end
end
