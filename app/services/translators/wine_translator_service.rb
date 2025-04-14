# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Translators
  class WineTranslatorService
    include Dry::Monads[:result, :try]
    include Dry::Monads::Do

    attr_reader :wine, :language, :system_message

    def initialize(wine, language)
      @wine = wine
      @language = language
      @system_message = %(Actúa como un servicio de traducción. El usuario te pasará la descripción de un vino y tú debes
    responder solamente con la traducción precisa de la descripción dada. Traducirás al #{language}.)
    end

    def call
      translate
    end

    private

    def translate
      description_translation = yield request_translation(@system_message, @wine.description)
      store_translations(description_translation)
    end

    def request_translation(system_message, text)
      GeminiAiService.call(
        system_msg: system_message,
        prompt: text,
        temperature: @temperature
      )
    end

    def store_translations(description_translation)
      Try[ActiveRecord::ActiveRecordError] do
        @wine.update!(
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
