# frozen_string_literal: true

class GeminiAiService < DryService
  include HTTParty

  def initialize(system_msg:, prompt:, model: 'gemini-2.0-flash', temperature: 0.2)
    @system_msg = system_msg
    @prompt = prompt
    @model = model
    @temperature = temperature
    @url = "https://generativelanguage.googleapis.com/v1beta/models/#{@model}:generateContent?key=#{ENV.fetch('GEMINI_KEY', nil)}"
    @headers = {
      'Content-Type': 'application/json',
    }
  end

  def call
    request_body = prepare_request
    perform_request(request_body)
  end

  private

  def prepare_request
    {}.tap do |body|
      body[:contents] = [
        {
          parts: [
            {
              text: @prompt,
            },
          ],
        },
      ]

      if @system_msg.present?
        body[:system_instruction] = {
          parts: [
            {
              text: @system_msg,
            },
          ],
        }
      end

      if @temperature.present?
        body[:generationConfig] = {
          temperature: @temperature,
        }
      end
    end
  end

  def perform_request(request_body)
    response = self.class.post(
      @url,
      headers: @headers,
      body: request_body.to_json
    )

    return Failure(error: response) unless response.success?

    content = response.dig('candidates', 0, 'content', 'parts', 0, 'text')

    Success(content)
  end
end
