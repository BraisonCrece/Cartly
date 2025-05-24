# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Translators
  class DrinkTranslatorService
    include Dry::Monads[:result, :try]
    include Dry::Monads::Do

    def initialize(drink, language)
      @drink = drink
      @language = language
      @name_system_message = prompt('el nombre', key_to_lang(language))
      @description_system_message = prompt('la descripción', key_to_lang(language))
    end

    def call
      translate
    end

    private

    def prompt(attribute, lang)
      %(Actúa como un servicio de traducción. El usuario te pasará #{attribute}
        de una bebida y debes responder solamente y directamente con la traducción
        precisa de la bebida. Traducirás al #{lang}.)
    end

    def translate
      debugger
      name_translation = yield request_translation(@name_system_message, @drink.name)
      description_translation = yield request_translation(@description_system_message, @drink.description)
      store_translations(name_translation, description_translation)
    end

    def request_translation(system_message, text)
      GeminiAiService.call(
        system_msg: system_message,
        prompt: text,
        temperature: @temperature
      )
    end

    def store_translations(name_translation, description_translation)
      Try[ActiveRecord::ActiveRecordError] do
        @drink.update!(
          "name_#{@language}": name_translation,
          "description_#{@language}": description_translation
        )
      end.to_result
    end

    def key_to_lang(lang_key)
      {
        gl: 'Gallego',
        cat: 'Catalán',
        eus: 'Euskera',
        en: 'Inglés',
        fr: 'Francés',
        de: 'Alemán',
        it: 'Italiano',
        ru: 'Ruso',
        pt: 'Portugués',
      }[lang_key]
    end
  end
end
