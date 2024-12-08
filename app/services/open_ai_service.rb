# frozen_string_literal: true

# rubocop:disable Metrics
class OpenAiService
  include HTTParty
  base_uri 'https://api.openai.com/v1'

  def initialize
    @api_key = ENV.fetch('OPENAI_KEY') # Replace with your OpenAI API key
    @headers = {
      Authorization: "Bearer #{@api_key}",
      'Content-Type': 'application/json',
    }
  end

  def request(
    system_message:,
    prompt:,
    example_prompt:,
    example_response:,
    model: 'gpt-4o-mini',
    temperature: 0.7
  )
    body = {
      model: model,
      messages: [
        { role: 'system', content: system_message },
        { role: 'user', content: example_prompt },
        { role: 'assistant', content: example_response },
        { role: 'user', content: prompt },
      ],
      temperature: temperature,
    }

    response = self.class.post('/chat/completions', headers: @headers, body: body.to_json)

    return Response.new(error: response.message) unless response.success?

    Response.new(content: response['choices'][0]['message']['content'])
  end

  class Response
    attr_reader :content, :error

    def initialize(content: nil, error: nil)
      @content = content
      @error = error
    end

    def success?
      @content.present?
    end
  end
end
# rubocop:enable Metrics
