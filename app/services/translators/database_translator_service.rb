# frozen_string_literal: true

module Translators
  class DatabaseTranslatorService < DryService
    def call
      categories = Category.all
      dishes = Dish.all
      wines = Wine.all
      allergens = Allergen.all

      translate(
        categories: categories,
        dishes: dishes,
        wines: wines,
        allergens: allergens
      )
    end

    private

    def translate(categories:, dishes:, wines:, allergens:)
      translate_collection(categories)
      translate_collection(dishes)
      translate_collection(wines)
      translate_collection(allergens)

      Success('All translations completed')
    end

    def translate_collection(collection)
      Parallel.each(collection, in_threads: 4) do |item|
        NewItemTranslatorService.new(item).call
      end
    end
  end
end
