# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Translators
  class DishTranslatorService
    include Dry::Monads[:result, :try]
    include Dry::Monads::Do.for(:call)

    attr_reader :dish, :language, :temperature, :model, :title_system_message, :description_system_message,
                :example_title, :example_description, :example_title_response, :example_description_response

    def initialize(dish, language, temperature: 0.3, model: 'gpt-4o-mini')
      @dish = dish
      @language = language
      @temperature = temperature
      @model = model
      @title_system_message = %(Actúa como un servicio de traducción. O ususario pasarache o nome dun prato de comida ou postre e debes
      respostar soamente coa traducción precisa do prato de comida, postre ou alimento. Traducirás do Galego ao #{language}.)
      @description_system_message = %(Actúa como un servicio de traducción. O ususario pasarache a descripción dun prato de comida ou postre e debes
      respostar soamente coa traducción precisa da descripción do prato de comida, postre ou alimento. Traducirás do Galego ao #{language}.)
    end

    def call
      yield initialize_example_prompts
      file_path = yield get_file_path
      file_content = yield get_file_content(file_path)
      title_translation = yield ask_for_translation(title_system_message, example_title, example_title_response,
                                                    dish.title)
      description_translation = yield ask_for_translation(description_system_message, example_description,
                                                          example_description_response, dish.description)
      save_translation(file_path, file_content, title_translation, description_translation)
    end

    private

    def initialize_example_prompts
      @example_title = 'Berenxena gratinada con queixo'
      @example_description = 'Berenxena ao forno, recuberta de queixo fundido con herbas aromáticas engaden frescura e profundidade a este clásico mediterráneo.'
      @example_title_response, @example_description_response = example_responses(language)
      Success('Example prompts initialized')
    end

    def get_file_path
      language_key = get_language_key(language)
      return Failure('Language not found') if language_key.nil?

      file_path = Rails.root.join('config', 'locale', "#{language_key}.yml")
      Success(file_path)
    end

    def get_file_content(file_path)
      if File.exist?(file_path)
        Success(YAML.load_file(file_path))
      else
        Failure('File not found')
      end
    end

    def ask_for_translation(system_message, example_prompt, example_response, prompt)
      result = OpenAiService.new.request(system_message:, prompt:, example_prompt:, example_response:, model:,
                                         temperature: 0.3)
      if result.success?
        # Remove the final period in case it was added by the AI
        result.content.chomp!('.') if result.content.end_with?('.')
        Success(result.content)
      else
        Failure(result.error)
      end
    end

    def save_translation(file_path, file_content, title_translation, description_translation)
      language_key = get_language_key(language)

      # Initialize structure if it doesn't exist
      file_content[language_key] ||= {}
      file_content[language_key]['dish'] ||= {}

      file_content[language_key]['dish'][dish.id] = {
        'title' => title_translation,
        'description' => description_translation,
      }

      result = Try[Errno::ENOENT, Errno::EACCES] do
        File.write(file_path, YAML.dump(file_content))
      end.to_result

      Rails.logger.error("Failed to save translation: #{result.failure}") if result.failure?
      result
    end

    def get_language_key(language)
      case language
      when 'Inglés'
        'en'
      when 'Español'
        'es'
      when 'Alemán'
        'de'
      when 'Italiano'
        'it'
      when 'Francés'
        'fr'
      when 'Ruso'
        'ru'
      end
    end

    def example_responses(language)
      case language
      when 'Inglés'
        ['Eggplant gratin with cheese',
         'Oven-baked eggplant, covered with melted cheese with aromatic herbs that add freshness and depth to this Mediterranean classic.',]
      when 'Español'
        ['Berenjena gratinada con queso',
         'Berenjena al horno, recubierta de queso fundido con hierbas aromáticas que añaden frescura y profundidad a este clásico mediterráneo.',]
      when 'Alemán'
        ['Überbackene Auberginen mit Käse',
         'Gebackene Auberginen, überzogen mit geschmolzenem Käse und aromatischen Kräutern, die diesem mediterranen Klassiker Frische und Tiefe verleihen.',]
      when 'Italiano'
        ['Melanzane gratinate con formaggio',
         'Melanzane al forno, ricoperte di formaggio fuso con erbe aromatiche che aggiungono freschezza e profondità a questo classico mediterraneo.',]
      when 'Francés'
        ['Aubergines gratinées au fromage',
         "Aubergine cuite, recouverte de fromage fondu et d'herbes aromatiques qui ajoutent de la fraîcheur et de la profondeur à ce classique méditerranéen.",]
      when 'Ruso'
        ['Баклажаны в гратене с сыром',
         'Запеченный баклажан, покрытый расплавленным сыром с ароматными травами, которые придают свежесть и глубину этой средиземноморской классике.',]
      end
    end
  end
end
