# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Translators
  class NewItemTranslatorService
    include Dry::Monads[:result, :try]
    include Dry::Monads::Do

    # Español va a ser el default de la app
    LANGUAGES = [:cat, :gl, :eus, :en, :fr, :it, :de, :pt, :ru].freeze

    attr_reader :item, :model, :temperature

    def initialize(item, model: 'gpt-4o-mini', temperature: 0.3)
      @item = item
      @model = model
      @temperature = temperature
    end

    def call
      yield process_item_translations
      unlock_item!
    end

    private

    def process_item_translations
      result = LANGUAGES.each do |language|
        service = Try[NameError] do
          "Translators::#{item.class.name}TranslatorService"
            .constantize
            .new(item, language)
        end.to_result

        raise "Service #{item.class.name}TranslatorService not found" if service.failure?

        result = service.success.call
        if result.success?
          Rails.logger.info("#{item.class.name} #{item.id} translated to #{language}")
          Success("#{item.class.name} #{item.id} translated")
        else
          Rails.logger.error("#{item.class.name} #{item.id} failed to translate to #{language}, #{result.failure}")
          Failure("#{item.class.name} #{item.id} failed to translate")
        end
      end
      result.all? ? Success('All translations successful') : Failure("Failed translations: #{result.filter(&:failure?).map(&:failure).join(', ')}")
    end

    def unlock_item!
      Try[ActiveRecord::RecordInvalid] do
        item.update(lock: false, active: true) unless item.instance_of?(::Allergen) || item.instance_of?(::Category)
      end.to_result
    end
  end
end
