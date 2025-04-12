# frozen_string_literal: true

class DescriptionService
  SYSTEM_MESSAGES = {
    plato: 'Eres un experto en cocina y en definir platos para la carta de un restaurante. Tus respuestas se limitan a dar la descripción de un plato de manera profesional y atractiva, limitándola a 300 caracteres para mantener concisión e interés. Devuelve directamente la descripción del plato sin añadir nada más.',
    vino: 'Eres un experto en vinos y en describir estos vinos para la carta de un restaurante. Para cada vino, genera una descripción breve en gallego. Destaca sabor, color, matices y notas de cata, tipo de uva, región de origen y recomendaciones de maridaje cuando sea pertinente. Limítala a 300 caracteres para mantener concisión e interés. El formato de tus respuestas debe ser solamente la descripción en sí, nada más.',
  }.freeze

  def initialize(plato:, image: nil, type: 'plato')
    @plato = plato
    @image = image
    @type = type.to_sym
  end

  def generate
    result = GeminiAiService.new(
      system_msg: SYSTEM_MESSAGES[@type],
      prompt: "Describe este #{@type}: \"#{@plato}\"",
      image: clean_base_64(@image),
      temperature: 1
    ).call

    raise result.failure[:error] unless result.success?

    result.value!
  end

  private

  def clean_base_64(image)
    return unless image.present?

    image.sub(%r{^data:image/[^;]+;base64,}, '')
  end
end
