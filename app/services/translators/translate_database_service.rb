# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Translators
  class TranslateDatabaseService
    include Dry::Monads[:result, :try]
    include Dry::Monads::Do

    attr_reader :yaml, :dishes, :wines, :allergens

    LANGUAGES = ['Español', 'Inglés', 'Francés', 'Alemán', 'Italiano', 'Ruso'].freeze

    def call
      yield fetch_items
      yield process_dishes_translations
      yield process_wines_translations
      yield process_allergens_translations
      yield reload_i18n_backend
    end

    private

    def fetch_items
      @dishes = Dish.all
      @wines = Wine.all
      @allergens = Allergen.all
      Success('Items loaded')
    end

    def process_dishes_translations
      dishes.each do |dish|
        NewItemTranslatorService.new(dish).call
      end
      Success('Dishes translations processed')
    end

    def process_wines_translations
      wines.each do |wine|
        NewItemTranslatorService.new(wine).call
      end
      Success('Wines translations processed')
    end

    def process_allergens_translations
      allergens.each do |allergen|
        NewItemTranslatorService.new(allergen).call
      end
      Success('Allergens translations processed')
    end

    def reload_i18n_backend
      Success('All done! :)')
    end
  end
end
