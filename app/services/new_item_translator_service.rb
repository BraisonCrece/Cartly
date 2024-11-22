# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

class NewItemTranslatorService
  include Dry::Monads[:result, :try]
  include Dry::Monads::Do.for(:call)

  LANGUAGES = ['Español', 'Inglés', 'Francés', 'Alemán', 'Italiano', 'Ruso'].freeze
  attr_reader :item, :model, :temperature

  def initialize(item, model: 'gpt-4o-mini', temperature: 0.3)
    @item = item
    @model = model
    @temperature = temperature
  end

  def call
    yield process_item_translations
    yield unlock_item
    yield reload_i18n
  end

  private

  def process_item_translations
    result = LANGUAGES.map do |language|
      service = instance_translator_service(item, language)
                .value_or { |error| Failure(error) }

      service.call
             .or { |error| Failure(error) }
    end

    return Failure("Failed translations: #{result.filter(&:failure?).map(&:failure).join(', ')}") unless result.all?(&:success?)

    Success('All translations successful')
  end

  def unlock_item
    Try[ActiveRecord::RecordInvalid] do
      item.update(lock: false, active: true)
    end.to_result
  end

  def reload_i18n
    I18n.reload!
    Success('Item translated and reloaded I18n')
  end

  def instance_translator_service(item, language)
    service = Try[NameError] do
      "#{item.class.name}TranslatorService".constantize.new(item, language, model:, temperature:)
    end.to_result

    return Failure("Service #{item.class.name}TranslatorService not found") if service.failure?

    service
  end
end
