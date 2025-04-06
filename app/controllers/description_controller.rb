# frozen_string_literal: true

class DescriptionController < ApplicationController
  before_action :authenticate_restaurant!

  def describe_dish
    plato = params[:plato]
    description_type = params[:description_type] || 'plato'

    system_messages = {
      plato: 'Eres un experto en cocina y en definir platos para la carta de un restaurante. Tus respuestas se limitan a dar la descripción de un plato de manera profesional y atractiva, limitándola a 300 caracteres para mantener concisión e interés. Devuelve directamente la descripción del plato sin añadir nada más.',
      vino: 'Eres un experto en vinos y en describir estos vinos para la carta de un restaurante. Para cada vino, genera una descripción breve en gallego. Destaca sabor, color, matices y notas de cata, tipo de uva, región de origen y recomendaciones de maridaje cuando sea pertinente. Limítala a 300 caracteres para mantener concisión e interés. El formato de tus respuestas debe ser solamente la descripción en sí, nada más.',
    }

    system = system_messages[description_type.to_sym]
    prompt = "Describe este #{description_type}: \"#{plato}\""

    begin
      result = GeminiAiService.new(
        system_msg: system,
        prompt: prompt,
        temperature: 1
      ).call

      if result.success?
        description = result.value!
        render json: { description: description }, status: :ok
      else
        render json: { error: result.failure[:error] }, status: :unprocessable_entity
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
