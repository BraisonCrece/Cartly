# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Translators
  class AllergenTranslatorService
    include Dry::Monads[:result, :try]
    include Dry::Monads::Do

    attr_reader :allergen, :language, :temperature, :model, :name_system_message,
                :example_name, :example_name_response

    def initialize(allergen, language)
      @allergen = allergen
      @language = language
      @name_system_message = %(Actúa como un servicio de traducción. El usuario te enviará el nombre de un alérgeno alimentario y debes
      responder solamente con la traducción precisa del alérgeno. Traducirás del Gallego al #{language}.)
    end

    def call
      translate
    end

    private

    def translate
      name_translation = yield request_translation(@name_system_message, @allergen.name)
      store_translations(name_translation)
    end

    def request_translation(system_message, text)
      GeminiAiService.call(
        system_msg: system_message,
        prompt: text,
        temperature: @temperature
      )
    end

    def store_translations(name_translation)
      Try[ActiveRecord::ActiveRecordError] do
        @allergen.update!(
          "name_#{@language}": name_translation
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
