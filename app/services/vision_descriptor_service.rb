# frozen_string_literal: true

class VisionDescriptorService < DryService
  option :image
  option :plato, optional: true

  def call
    client = OpenAI::Client.new
    prompt = yield build_prompt
    describe_image(client, prompt)
  end

  private

  PROMPT = 'Describe esta imagen de un plato de comida para un menú de restaurante.
            Has de ser preciso y acertar con los ingredientes.'

  def build_prompt
    prompt = PROMPT
    prompt += " El nombre del plato es #{plato}" if plato

    messages_content = [
      {
        type: 'text',
        text: prompt,
      },
      {
        type: 'image_url',
        image_url: {
          url: "data:image/jpeg;base64,#{image}",
        },
      },
    ]

    Success(messages_content)
  end

  def describe_image(client, messages_content)
    response = client.chat(
      parameters: {
        model: 'gpt-4o',
        messages: [
          {
            role: 'user',
            content: JSON.dump(messages_content),
          },
        ],
      }
    )

    Success(response)
  end
end
