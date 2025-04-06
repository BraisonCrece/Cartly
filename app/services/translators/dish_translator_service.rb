# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Translators
  class DishTranslatorService
    include Dry::Monads[:result, :try]
    include Dry::Monads::Do

    def initialize(dish, language)
      @dish = dish
      @language = language
      @title_system_message = prompt('el nombre', key_to_lang(language))
      @description_system_message = prompt('la descripción', key_to_lang(language))
    end

    def call
      translate
    end

    private

    def prompt(attribute, lang)
      %(Actúa como un servicio de traducción. El usuario te pasará #{attribute}
      de un plato de comida o postre y debes responder solamente con la traducción
      precisa del plato de comida, postre o alimento. Traducirás del Castellano al #{lang}.)
    end

    def translate
      title_translation = yield request_translation(@title_system_message, @dish.title)
      description_translation = yield request_translation(@description_system_message, @dish.description)
      store_translations(title_translation, description_translation)
    end

    def request_translation(system_message, text)
      GeminiAiService.call(
        system_msg: system_message,
        prompt: text,
        temperature: @temperature
      )
    end

    def store_translations(title_translation, description_translation)
      Try[ActiveRecord::ActiveRecordError] do
        @dish.update!(
          "title_#{@language}": title_translation,
          "description_#{@language}": description_translation
        )
      end.to_result
    end

    def key_to_lang(lang_key)
      case lang_key
      when :gl
        'Gallego'
      when :cat
        'Catalán'
      when :eus
        'Euskera'
      when :en
        'Inglés'
      when :fr
        'Francés'
      when :de
        'Alemán'
      when :it
        'Italiano'
      when :ru
        'Ruso'
      when :pt
        'Portugués'
      end
    end
  end
end
