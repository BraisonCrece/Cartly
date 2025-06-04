# frozen_string_literal: true

module ControlPanel
  class CategoryOptionsService
    def self.call(filter_type, drink_categories: nil, wine_denominations: nil)
      new(filter_type, drink_categories, wine_denominations).call
    end

    def initialize(filter_type, drink_categories, wine_denominations)
      @filter_type = filter_type
      @drink_categories = drink_categories
      @wine_denominations = wine_denominations
    end

    def call
      case @filter_type
      when 'drinks'
        drinks_options
      when 'food'
        food_options
      when 'wines'
        wines_options
      else
        default_options
      end
    end

    private

    def drinks_options
      base_options + (@drink_categories&.map { |cat| [cat.name, cat.id] } || [])
    end

    def food_options
      [['Todas', 'all'], ['Menu del dia', 'daily'], ['Carta', 'menu']]
    end

    def wines_options
      options = base_options.dup
      @wine_denominations&.each do |wine_type, denominations|
        options += denominations.map { |denom| ["#{wine_type} - #{denom.name}", denom.id] }
      end
      options
    end

    def default_options
      base_options
    end

    def base_options
      [['Todas', 'all']]
    end
  end
end
